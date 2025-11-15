import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../main.dart';
import '../screens/map_screen.dart';
import '../services/auth_service.dart';

/// Tela de menu inicial
class MenuScreen extends StatefulWidget { 
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  bool _mapExpanded = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _mapHeightAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // --- LÓGICA DE AUTO-LOGIN ---
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppConstants.routeMainMenu);
      });
    }

    // --- INICIALIZAÇÃO DA ANIMAÇÃO ---
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _mapHeightAnimation = Tween<double>(
      begin: 300.0,
      end: 750.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Expande o mapa e navega para MapScreen
  Future<void> _expandMapAndNavigate() async {
    setState(() {
      _mapExpanded = true;
    });
    
    await _animationController.forward();
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const MapScreen()),
      ).then((_) {
        // when returning from map, reverse the animation and collapse
        if (mounted) {
          setState(() => _mapExpanded = false);
          _animationController.reverse();
        }
      });
    }
  }

  /// Login anônimo
  Future<void> _handleAnonymousLogin() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final credential = await authService.signInAnonymously();

      if (credential != null && mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        
        // Login como visitante anônimo
        await userProvider.login(
          0, // ID 0 para anônimos
          'Visitante',
          'anonimo@mapguaru.app',
        );

        _showSnackBar('Entrando como visitante...', isError: false);

        Navigator.of(context).pushReplacementNamed(
          AppConstants.routeMainMenu,
        );
      } else if (mounted) {
        _showSnackBar('Erro ao entrar como visitante');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao acessar o app');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- SEÇÃO DO MAPA INTERATIVO ---
              _buildMapSection(), 
              
              // --- BOTÕES DE AÇÃO ---
              _buildActionButtons(context),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget do Mapa Interativo
  Widget _buildMapSection() {
    return AnimatedBuilder(
      animation: _mapHeightAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _mapExpanded ? null : _expandMapAndNavigate,
          child: Container(
            height: _mapExpanded ? _mapHeightAnimation.value : 350,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
              ),
              borderRadius: _mapExpanded
                  ? BorderRadius.zero
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: CustomPaint(
                      painter: MapPatternPainter(),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(51, 0, 0, 0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _mapExpanded ? Icons.map : Icons.location_on,
                          size: 70,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _mapExpanded ? 'Carregando mapa...' : 'Explorar Mapa',
                        style: const TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                if (!_mapExpanded)
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _mapExpanded ? null : _expandMapAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          foregroundColor: AppTheme.primaryColor,
                          elevation: 6,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          side: BorderSide(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0,2))],
                              ),
                              child: const Icon(Icons.explore, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            // constrain text area to avoid overflow on small screens
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Toque para explorar',
                                    style: TextStyle(fontFamily: 'Helvetica', fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Descubra pontos e rotas na cidade',
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Top-left badge with city and count
                if (!_mapExpanded)
                  Positioned(
                    top: 18,
                    left: 18,
                    child: Card(
                      elevation: 4,
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.location_city, color: AppTheme.primaryColor, size: 18),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Guarulhos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text('Mapa interativo', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Botões de Ação
  Widget _buildActionButtons(BuildContext context) {
    final primaryStyle = ElevatedButton.styleFrom(
      backgroundColor: AppTheme.tertiaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minimumSize: const Size.fromHeight(50),
    );

    final secondaryElevated = ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minimumSize: const Size.fromHeight(50),
    );

    final subtleElevated = ElevatedButton.styleFrom(
      backgroundColor: AppTheme.accentColor,
      foregroundColor: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minimumSize: const Size.fromHeight(50),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // header
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.explore, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bem-vindo', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('Encontre serviços públicos e rotas pela cidade', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Primary login
              ElevatedButton(
                onPressed: _isLoading ? null : () { Navigator.of(context).pushNamed(AppConstants.routeLogin); },
                style: primaryStyle,
                child: const Text('Fazer login', style: TextStyle(fontFamily: 'Helvetica', fontSize: 16)),
              ),
              const SizedBox(height: 12),

              // Secondary register (Elevated)
              ElevatedButton(
                onPressed: _isLoading ? null : () { Navigator.of(context).pushNamed(AppConstants.routeRegister); },
                style: secondaryElevated,
                child: const Text('Realizar cadastro', style: TextStyle(fontFamily: 'Helvetica', fontSize: 16)),
              ),
              const SizedBox(height: 12),

              // Divider with label
              Row(children: [const Expanded(child: Divider()), const SizedBox(width: 12), Text('OU', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(width: 12), const Expanded(child: Divider())]),
              const SizedBox(height: 12),

              // Anonymous / visitor entry (Elevated subtle)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleAnonymousLogin,
                icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.person_outline),
                label: Text(_isLoading ? 'Entrando...' : 'Entrar como visitante',
                style: const TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 16
                )),
                style: subtleElevated,
              ),

              const SizedBox(height: 14),

              // Info sobre visitante
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.info.withOpacity(0.22), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Como visitante, você pode explorar o app mas não salvar favoritos.', style: TextStyle(fontFamily: 'Helvetica', fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.4))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Classe Painter
class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 8; i++) {
      final y = size.height / 8 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (var i = 0; i < 6; i++) {
      final x = size.width / 6 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final markerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final markers = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.4, size.height * 0.7),
    ];

    for (var marker in markers) {
      canvas.drawCircle(marker, 6, markerPaint);
      final path = Path()
        ..moveTo(marker.dx, marker.dy)
        ..lineTo(marker.dx - 4, marker.dy + 8)
        ..lineTo(marker.dx + 4, marker.dy + 8)
        ..close();
      canvas.drawPath(path, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}