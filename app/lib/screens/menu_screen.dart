import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../main.dart';
import '../screens/map_screen.dart';

/// Tela de menu inicial
class MenuScreen extends StatefulWidget { 
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  bool _mapExpanded = false;
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
      begin: 300.0, // Altura inicial um pouco maior
      end: 750.0,   // Altura expandida
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    // --- FIM DA INICIALIZAÇÃO DA ANIMAÇÃO ---
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MapScreen()),
      );
    }
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
            height: _mapExpanded ? _mapHeightAnimation.value : 350, // Altura inicial
            width: double.infinity, // Ocupar toda a largura
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
                      painter: MapPatternPainter(), // A classe do Painter está abaixo
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
                          color: const Color.fromRGBO(255, 255, 255, 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _mapExpanded ? Icons.map : Icons.location_on,
                          size: 80,
                          color: Colors.white,
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
                      Text(
                        _mapExpanded
                            ? 'Aguarde um momento'
                            : 'Descubra os pontos da cidade', // Subtítulo
                        style: const TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16, // Aumentado
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_mapExpanded)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Toque para explorar',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(width: 16),
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 24), // Espaço após o mapa
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.routeLogin);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                  style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 16,
                ),
                'Fazer login'),
            ),
          ),
          
          const SizedBox(height: 14),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.routeRegister);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              child: const Text(
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 16,
                  fontWeight: FontWeight.w600
                ),
                'Realizar cadastro'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                AppConstants.routeMainMenu,
              );
            },
            child: Text(
              'Acessar como visitante',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                color: AppTheme.primaryColor,
                decoration: TextDecoration.underline,
                decorationColor: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
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