import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Tela de guia de serviços
/// 
/// Exibe informações sobre como usar o aplicativo e os serviços disponíveis
class ServiceGuideScreen extends StatelessWidget {
  const ServiceGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guia de Serviços'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introdução
            _buildIntroCard(),
            
            const SizedBox(height: 24),
            
            // Como usar
            _buildSection(
              'Como Usar o MapGuaru',
              Icons.help_outline,
              [
                _buildStepCard(
                  '1',
                  'Escolha uma Categoria',
                  'Selecione entre Saúde, Educação, Comunidade, Segurança, Transporte ou Cultura & Lazer',
                  AppTheme.primaryColor,
                ),
                _buildStepCard(
                  '2',
                  'Explore os Locais',
                  'Veja a lista de unidades disponíveis com endereços e informações de contato',
                  AppTheme.accentColor,
                ),
                _buildStepCard(
                  '3',
                  'Visualize no Mapa',
                  'Use o mapa interativo para ver a localização exata e encontrar o caminho',
                  AppTheme.success,
                ),
                _buildStepCard(
                  '4',
                  'Salve seus Favoritos',
                  'Faça login e adicione seus locais favoritos para acesso rápido',
                  Colors.red,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Categorias detalhadas
            _buildSection(
              'Categorias de Serviços',
              Icons.category,
              List.generate(6, (index) {
                final categoryId = index + 1;
                return _buildCategoryCard(
                  categoryId,
                  AppConstants.categoryNames[categoryId]!,
                  AppConstants.categoryDescriptions[categoryId]!,
                );
              }),
            ),
            
            const SizedBox(height: 24),
            
            // Dicas
            _buildSection(
              'Dicas Úteis',
              Icons.lightbulb_outline,
              [
                _buildTipCard(
                  'Verifique o Horário',
                  'Sempre confira o horário de funcionamento antes de ir',
                  Icons.access_time,
                ),
                _buildTipCard(
                  'Leve Documentos',
                  'Tenha seus documentos pessoais em mãos',
                  Icons.description,
                ),
                _buildTipCard(
                  'Use o Telefone',
                  'Ligue antes para confirmar atendimento e tirar dúvidas',
                  Icons.phone,
                ),
                _buildTipCard(
                  'Favorite os Locais',
                  'Adicione aos favoritos os serviços que você mais usa',
                  Icons.favorite,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Contato
            _buildContactCard(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Constrói card de introdução
  Widget _buildIntroCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.map,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Bem-vindo ao MapGuaru',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Seu guia completo para encontrar e acessar serviços públicos em Guarulhos. Navegue por categorias, visualize no mapa e salve seus favoritos.',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói seção com título
  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  /// Constrói card de passo
  Widget _buildStepCard(String number, String title, String description, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói card de categoria
  Widget _buildCategoryCard(int categoryId, String name, String description) {
    final color = AppTheme.getCategoryColor(categoryId);
    final icon = AppTheme.getCategoryIcon(
      ['health', 'education', 'community', 'security', 'transport', 'culture'][categoryId - 1],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói card de dica
  Widget _buildTipCard(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói card de contato
  Widget _buildContactCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.support_agent, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Precisa de Ajuda?',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Entre em contato com a Prefeitura de Guarulhos para mais informações sobre os serviços:',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.phone,
              'Telefone',
              '156 (SAC Guarulhos)',
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.language,
              'Website',
              'www.guarulhos.sp.gov.br',
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.email,
              'E-mail',
              'atendimento@guarulhos.sp.gov.br',
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói item de contato
  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}