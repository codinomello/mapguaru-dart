import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Tela com guia cultural, histórico e curiosidades de Guarulhos
class CityGuideScreen extends StatefulWidget {
  const CityGuideScreen({super.key});

  @override
  State<CityGuideScreen> createState() => _CityGuideScreenState();
}

class _CityGuideScreenState extends State<CityGuideScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guia de Guarulhos'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: 'História'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Curiosidades'),
            Tab(icon: Icon(Icons.location_city), text: 'Geografia'),
            Tab(icon: Icon(Icons.directions_bus), text: 'Mobilidade'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(),
          _buildCuriositiesTab(),
          _buildGeographyTab(),
          _buildMobilityTab(),
        ],
      ),
    );
  }

  /// Aba de História
  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildSectionHeader(
            'História de Guarulhos',
            'Conheça a trajetória da cidade',
            Icons.history,
            const Color(0xFF4338CA),
          ),
          
          const SizedBox(height: 24),
          
          // Timeline
          _buildTimelineItem(
            '1560',
            'Fundação',
            'Guarulhos foi fundada pelo padre jesuíta Manuel de Paiva, sendo uma das mais antigas cidades do Brasil.',
            const Color(0xFF4338CA),
          ),
          
          _buildTimelineItem(
            '1880',
            'Industrialização',
            'Início do processo de industrialização com a chegada da ferrovia São Paulo Railway.',
            const Color(0xFF059669),
          ),
          
          _buildTimelineItem(
            '1945',
            'Emancipação',
            'Guarulhos se torna município independente, separando-se de São Paulo.',
            const Color(0xFF2563EB),
          ),
          
          _buildTimelineItem(
            '1985',
            'Aeroporto Internacional',
            'Inauguração do Aeroporto Internacional de São Paulo, transformando a cidade.',
            const Color(0xFF7C3AED),
          ),
          
          _buildTimelineItem(
            '2024',
            'Atualidade',
            'Segunda maior cidade de São Paulo, importante polo industrial e comercial.',
            const Color(0xFFEA580C),
          ),
          
          const SizedBox(height: 24),
          
          // Card informativo
          _buildInfoCard(
            'Patrimônio Histórico',
            'A cidade preserva importantes marcos históricos como a Igreja de Nossa Senhora da Conceição (1675) e o Museu Histórico Municipal.',
            Icons.account_balance,
          ),
        ],
      ),
    );
  }

  /// Aba de Curiosidades
  Widget _buildCuriositiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Curiosidades',
            'Fatos interessantes sobre Guarulhos',
            Icons.lightbulb,
            const Color(0xFFF59E0B),
          ),
          
          const SizedBox(height: 24),
          
          _buildCuriosityCard(
            'População',
            '1,4 milhão de habitantes',
            'Segunda maior cidade do estado de São Paulo',
            Icons.people,
            const Color(0xFF2563EB),
          ),
          
          _buildCuriosityCard(
            'Aeroporto',
            'Maior aeroporto da América Latina',
            'Movimenta mais de 40 milhões de passageiros por ano',
            Icons.flight,
            const Color(0xFF7C3AED),
          ),
          
          _buildCuriosityCard(
            'Indústria',
            'Forte polo industrial',
            'Abriga mais de 3.000 indústrias de diversos setores',
            Icons.factory,
            const Color(0xFF059669),
          ),
          
          _buildCuriosityCard(
            'Área Verde',
            'Parque Estadual da Cantareira',
            'Parte da maior floresta urbana nativa do mundo',
            Icons.park,
            const Color(0xFF10B981),
          ),
          
          _buildCuriosityCard(
            'Origem do Nome',
            'Homenagem aos índios Guarus',
            'Povo indígena que habitava a região',
            Icons.history_edu,
            const Color(0xFFDC2626),
          ),
          
          _buildCuriosityCard(
            'Economia',
            '10º maior PIB do Brasil',
            'Economia diversificada e forte setor de serviços',
            Icons.trending_up,
            const Color(0xFFEA580C),
          ),
          
          const SizedBox(height: 16),
          
          // Quiz interativo
          _buildQuizSection(),
        ],
      ),
    );
  }

  /// Aba de Geografia
  Widget _buildGeographyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Geografia',
            'Características geográficas da cidade',
            Icons.location_city,
            const Color(0xFF059669),
          ),
          
          const SizedBox(height: 24),
          
          _buildGeographyCard(
            'Localização',
            'Zona Leste da Região Metropolitana de São Paulo',
            Icons.place,
          ),
          
          _buildGeographyCard(
            'Área Total',
            '318,68 km² de território',
            Icons.square_foot,
          ),
          
          _buildGeographyCard(
            'Altitude',
            '759 metros acima do nível do mar',
            Icons.terrain,
          ),
          
          _buildGeographyCard(
            'Clima',
            'Subtropical úmido com verões quentes',
            Icons.wb_sunny,
          ),
          
          _buildGeographyCard(
            'Relevo',
            'Planalto, com morros e várzeas',
            Icons.landscape,
          ),
          
          _buildGeographyCard(
            'Hidrografia',
            'Bacia do Rio Tietê e Rio Cabuçu',
            Icons.water,
          ),
          
          const SizedBox(height: 24),
          
          // Bairros principais
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Principais Bairros',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildBairroChip('Centro'),
                  _buildBairroChip('Bonsucesso'),
                  _buildBairroChip('Cumbica'),
                  _buildBairroChip('Gopouva'),
                  _buildBairroChip('Pimentas'),
                  _buildBairroChip('Vila Galvão'),
                  _buildBairroChip('Jardim São Paulo'),
                  _buildBairroChip('Taboão'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Aba de Mobilidade Urbana
  Widget _buildMobilityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Mobilidade Urbana',
            'Como se locomover pela cidade',
            Icons.directions_bus,
            const Color(0xFF7C3AED),
          ),
          
          const SizedBox(height: 24),
          
          _buildMobilityCard(
            'Ônibus Municipal',
            '280+ linhas operando na cidade',
            'Sistema gerenciado pela ViaBus',
            Icons.directions_bus,
            const Color(0xFF2563EB),
          ),
          
          _buildMobilityCard(
            'Integração Metropolitana',
            'Conexão com São Paulo e região',
            'EMTU opera linhas intermunicipais',
            Icons.compare_arrows,
            const Color(0xFF059669),
          ),
          
          _buildMobilityCard(
            'Aeroporto GRU',
            'Acesso facilitado ao aeroporto',
            'Linhas diretas e serviço executivo',
            Icons.flight,
            const Color(0xFF7C3AED),
          ),
          
          _buildMobilityCard(
            'Rodovias',
            'Principais vias de acesso',
            'Via Dutra, Ayrton Senna, Fernão Dias',
            Icons.directions_car,
            const Color(0xFFEA580C),
          ),
          
          _buildMobilityCard(
            'Ciclofaixas',
            'Incentivo ao ciclismo',
            'Rede em expansão pela cidade',
            Icons.directions_bike,
            const Color(0xFF10B981),
          ),
          
          _buildMobilityCard(
            'Táxi e Apps',
            'Táxis e transporte por app',
            'Uber, 99, Cabify e táxis locais',
            Icons.local_taxi,
            const Color(0xFFF59E0B),
          ),
          
          const SizedBox(height: 24),
          
          // Dicas de mobilidade
          Card(
            color: AppTheme.info.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: AppTheme.info),
                      const SizedBox(width: 8),
                      const Text(
                        'Dicas de Mobilidade',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem('Use o app da ViaBus para consultar horários'),
                  _buildTipItem('Tenha cartão Bilhete Único para integração'),
                  _buildTipItem('Evite horários de pico (7h-9h e 17h-19h)'),
                  _buildTipItem('Planeje rotas com antecedência'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WIDGETS AUXILIARES ====================

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String year, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    year,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: color.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuriosityCard(String title, String subtitle, String description, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
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

  Widget _buildGeographyCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildMobilityCard(String title, String subtitle, String description, IconData icon, Color color) {
    return _buildCuriosityCard(title, subtitle, description, icon, color);
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Card(
      color: AppTheme.info.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.info, size: 32),
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 14,
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

  Widget _buildBairroChip(String bairro) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: Chip(
        label: Text(bairro),
        avatar: const Icon(Icons.location_on, size: 18),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppTheme.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSection() {
    return Card(
      color: AppTheme.accentColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.quiz, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                const Text(
                  'Quiz sobre Guarulhos',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Teste seus conhecimentos sobre a cidade!',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quiz em desenvolvimento!'),
                    backgroundColor: AppTheme.info,
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}