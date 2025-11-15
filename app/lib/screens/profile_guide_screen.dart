import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Guia completo do Perfil de Usuário
class ProfileGuideScreen extends StatefulWidget {
  const ProfileGuideScreen({super.key});

  @override
  State<ProfileGuideScreen> createState() => _ProfileGuideScreenState();
}

class _ProfileGuideScreenState extends State<ProfileGuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guia do Perfil'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              children: [
                _buildIntroPage(),
                _buildAccountPage(),
                _buildFavoritesPage(),
                _buildCustomMarkersPage(),
                _buildPreferencesPage(),
                _buildPrivacyPage(),
              ],
            ),
          ),
          _buildPageIndicator(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// Página 1: Introdução
  Widget _buildIntroPage() {
    return _buildGuidePage(
      icon: Icons.person,
      color: AppTheme.primaryColor,
      title: 'Seu Perfil no MapGuaru',
      description: 'Gerencie suas informações, favoritos e preferências.',
      features: [
        'Visualize e edite suas informações',
        'Gerencie seus favoritos',
        'Veja seus marcadores personalizados',
        'Configure preferências do app',
        'Controle de privacidade',
      ],
      image: Icons.account_circle,
    );
  }

  /// Página 2: Conta
  Widget _buildAccountPage() {
    return _buildGuidePage(
      icon: Icons.manage_accounts,
      color: AppTheme.success,
      title: 'Gerenciando sua Conta',
      description: 'Mantenha suas informações sempre atualizadas.',
      features: [
        '👤 Nome: Toque para editar',
        '📧 Email: Vinculado à sua conta',
        '🔒 Senha: Altere quando necessário',
        '📱 Conta anônima: Converta para permanente',
        '🚪 Logout: Saia com segurança',
      ],
      tips: [
        'Use um email válido para recuperação',
        'Escolha uma senha forte e única',
        'Mantenha seus dados atualizados',
      ],
    );
  }

  /// Página 3: Favoritos
  Widget _buildFavoritesPage() {
    return _buildGuidePage(
      icon: Icons.favorite,
      color: Colors.red,
      title: 'Seus Favoritos',
      description: 'Acesso rápido aos serviços que você mais usa.',
      features: [
        '⭐ Adicione aos favoritos: Toque no coração',
        '📋 Veja todos: Lista completa no perfil',
        '🗑️ Remova: Toque novamente no coração',
        '🔍 Busque: Encontre rapidamente',
        '📍 No mapa: Veja localização',
      ],
      tips: [
        'Favoritos sincronizam entre dispositivos',
        'Use favoritos para acesso rápido',
        'Organize por categoria',
      ],
    );
  }

  /// Página 4: Marcadores Personalizados
  Widget _buildCustomMarkersPage() {
    return _buildGuidePage(
      icon: Icons.add_location_alt,
      color: AppTheme.accentColor,
      title: 'Meus Marcadores',
      description: 'Locais especiais que você adicionou.',
      features: [
        '📍 Adicione no mapa: Toque longo',
        '📝 Edite informações: Nome, descrição, etc',
        '🏷️ Categorize: Organize por tipo',
        '📤 Compartilhe: Envie para amigos',
        '🗑️ Exclua: Remova quando quiser',
      ],
      tips: [
        'Ideal para locais que você frequenta',
        'Adicione notas importantes',
        'Use para lugares não cadastrados',
      ],
    );
  }

  /// Página 5: Preferências
  Widget _buildPreferencesPage() {
    return _buildGuidePage(
      icon: Icons.settings,
      color: AppTheme.info,
      title: 'Preferências e Configurações',
      description: 'Personalize sua experiência no app.',
      features: [
        '🌙 Tema: Claro, escuro ou automático',
        '🔔 Notificações: Ative alertas',
        '📍 Localização: Precisão do GPS',
        '🗺️ Mapa padrão: Tipo de visualização',
        '🔄 Sincronização: Automática ou manual',
      ],
      tips: [
        'Modo escuro economiza bateria (OLED)',
        'Desative notificações desnecessárias',
        'Alta precisão GPS consome mais bateria',
      ],
    );
  }

  /// Página 6: Privacidade
  Widget _buildPrivacyPage() {
    return _buildGuidePage(
      icon: Icons.security,
      color: AppTheme.securityColor,
      title: 'Privacidade e Segurança',
      description: 'Seus dados estão protegidos conosco.',
      features: [
        '🔒 Dados criptografados',
        '🙈 Localização privada',
        '❌ Sem venda de dados',
        '🗑️ Direito ao esquecimento',
        '📊 Controle de dados',
      ],
      tips: [
        'Leia nossa política de privacidade',
        'Você controla quais dados compartilha',
        'Exclua sua conta a qualquer momento',
      ],
    );
  }

  Widget _buildGuidePage({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required List<String> features,
    List<String>? tips,
    IconData? image,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Ícone grande
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              image ?? icon,
              size: 60,
              color: color,
            ),
          ),

          const SizedBox(height: 24),

          // Título
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Descrição
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Features
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 15,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          // Dicas
          if (tips != null && tips.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.info.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: AppTheme.info, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Dicas',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
              ),
            ),
          if (_currentPage > 0 && _currentPage < 5) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_currentPage < 5) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(_currentPage < 5 ? Icons.arrow_forward : Icons.check),
              label: Text(_currentPage < 5 ? 'Próximo' : 'Concluir'),
            ),
          ),
        ],
      ),
    );
  }
}