import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../main.dart';

/// Tela de splash exibida ao iniciar o aplicativo
///
/// Mostra o logo do MapGuaru e navega automaticamente
/// para a próxima tela após 2 segundos
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  // Animação de escala removida para um efeito mais suave

  @override
  void initState() {
    super.initState();

    // Configurar animação de fade
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200), // Duração suave
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Iniciar animação
    _controller.forward();

    // Navegar para próxima tela
    _navigateToNext();
  }

  /// Navega para a tela de menu após delay
  Future<void> _navigateToNext() async {
    // Carregar dados do usuário
    await Provider.of<UserProvider>(context, listen: false).loadUserData();

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppConstants.routeMenu);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo consistente com o tema do app
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone no estilo do app
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map, // Ícone principal
                  size: 50,
                  color: AppTheme.primaryColor,
                ),
              ),

              const SizedBox(height: 24),

              // Nome do app com cor de texto primária
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline com cor de texto secundária
              Text(
                AppConstants.appTagline,
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Indicador de carregamento
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}