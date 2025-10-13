import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../main.dart';

/// Tela de menu inicial
/// 
/// Oferece opções de login, cadastro ou acesso como visitante
/// Conforme o fluxograma fornecido
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Verificar se usuário já está logado
    final userProvider = Provider.of<UserProvider>(context);
    
    if (userProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppConstants.routeMainMenu);
      });
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),
                
                // Logo e título
                _buildHeader(),
                
                const SizedBox(height: 60),
                
                // Mapa ilustrativo
                _buildMapIllustration(),
                
                const Spacer(),
                
                // Botões de ação
                _buildActionButtons(context),
                
                const SizedBox(height: 16),
                
                // Divider com texto
                _buildDivider(),
                
                const SizedBox(height: 16),
                
                // Botões de login social
                _buildSocialButtons(),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o cabeçalho com logo e título
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.cardShadow,
          ),
          child: const Icon(
            Icons.map,
            size: 50,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          AppConstants.appName,
          style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          AppConstants.appTagline,
          style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Constrói ilustração do mapa
  Widget _buildMapIllustration() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Simulação de mapa
            Center(
              child: Icon(
                Icons.location_on,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Guarulhos, SP',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói botões principais de ação
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Botão Fazer login
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.routeLogin);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Fazer login'),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Botão Realizar cadastro
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.routeRegister);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            child: const Text('Realizar cadastro'),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Link: Acessar como visitante
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(
              AppConstants.routeMainMenu,
            );
          },
          child: const Text(
            'Acessar como visitante',
            style: TextStyle(
              fontFamily: 'Helvetica',
              color: Colors.white,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Constrói divider com texto
  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white38,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OU',
            style: TextStyle(
              fontFamily: 'Helvetica',
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white38,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  /// Constrói botões de login social
  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Facebook
        _buildSocialButton(
          icon: Icons.facebook,
          color: const Color(0xFF1877F2),
          onTap: () {
            // Implementar login com Facebook
          },
        ),
        
        const SizedBox(width: 16),
        
        // WhatsApp
        _buildSocialButton(
          icon: Icons.phone,
          color: const Color(0xFF25D366),
          onTap: () {
            // Implementar login com WhatsApp
          },
        ),
        
        const SizedBox(width: 16),
        
        // Instagram
        _buildSocialButton(
          icon: Icons.camera_alt,
          color: const Color(0xFFE4405F),
          onTap: () {
            // Implementar login com Instagram
          },
        ),
      ],
    );
  }

  /// Constrói botão de rede social circular
  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}