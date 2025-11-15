import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Guia completo de uso do Mapa Interativo
class MapGuideScreen extends StatefulWidget {
  const MapGuideScreen({super.key});

  @override
  State<MapGuideScreen> createState() => _MapGuideScreenState();
}

class _MapGuideScreenState extends State<MapGuideScreen> {
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
        title: const Text('Guia do Mapa'),
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
                _buildNavigationPage(),
                _buildMarkersPage(),
                _buildCustomMarkerPage(),
                _buildRoutesPage(),
                _buildLayersPage(),
                _buildTipsPage(),
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
      icon: Icons.map,
      color: AppTheme.primaryColor,
      title: 'Bem-vindo ao Mapa Interativo!',
      description: 'Explore todos os serviços públicos de Guarulhos em um mapa fácil de usar.',
      features: [
        'Visualize hospitais, escolas e muito mais',
        'Encontre o serviço mais próximo de você',
        'Crie marcadores personalizados',
        'Calcule rotas até os locais',
        'Ative camadas especiais do GeoServer',
      ],
      image: Icons.explore,
    );
  }

  /// Página 2: Navegação
  Widget _buildNavigationPage() {
    return _buildGuidePage(
      icon: Icons.navigation,
      color: AppTheme.success,
      title: 'Navegando pelo Mapa',
      description: 'Aprenda os gestos básicos para navegar.',
      features: [
        '👆 Toque: Selecione um marcador',
        '👉 Arraste: Mova o mapa',
        '🤏 Pinça: Zoom in/out',
        '🔄 Rotação: Gire com dois dedos',
        '📍 Botão "Minha Localização": Centraliza em você',
      ],
      tips: [
        'Use o botão de lista para ver todos os locais',
        'Toque em um marcador para ver detalhes',
      ],
    );
  }

  /// Página 3: Marcadores
  Widget _buildMarkersPage() {
    return _buildGuidePage(
      icon: Icons.place,
      color: AppTheme.healthColor,
      title: 'Entendendo os Marcadores',
      description: 'Cada cor representa uma categoria diferente.',
      features: [
        '🔵 Azul: Saúde (Hospitais, UBS)',
        '🟢 Verde: Educação (Escolas)',
        '🔴 Vermelho: Comunidade (Centros)',
        '🟠 Laranja: Segurança (Delegacias)',
        '🟣 Roxo: Transporte (Terminais)',
        '🟤 Marrom: Cultura (Museus, Teatros)',
      ],
      tips: [
        'Toque no marcador para ver informações',
        'Use filtros para mostrar apenas uma categoria',
      ],
    );
  }

  /// Página 4: Marcador Personalizado
  Widget _buildCustomMarkerPage() {
    return _buildGuidePage(
      icon: Icons.add_location_alt,
      color: AppTheme.accentColor,
      title: 'Marcadores Personalizados',
      description: 'Adicione seus próprios locais favoritos!',
      features: [
        '➕ Toque longo no mapa para adicionar',
        '📝 Dê um nome e descrição',
        '🏷️ Escolha uma categoria',
        '⭐ Marque como favorito',
        '📤 Compartilhe com amigos',
      ],
      tips: [
        'Seus marcadores são salvos automaticamente',
        'Acesse todos em Perfil > Meus Marcadores',
        'Edite ou exclua a qualquer momento',
      ],
    );
  }

  /// Página 5: Rotas
  Widget _buildRoutesPage() {
    return _buildGuidePage(
      icon: Icons.directions,
      color: AppTheme.info,
      title: 'Calculando Rotas',
      description: 'Encontre o melhor caminho até o serviço.',
      features: [
        '🚶 A pé: Rotas para pedestres',
        '🚗 De carro: Rotas otimizadas',
        '🚌 Transporte público: Em breve',
        '📏 Distância e tempo estimado',
        '🗺️ Visualização passo a passo',
      ],
      tips: [
        'Toque em "Traçar Rota" nos detalhes do local',
        'A rota é calculada da sua posição atual',
        'Acompanhe o trajeto em tempo real',
      ],
    );
  }

  /// Página 6: Camadas
  Widget _buildLayersPage() {
    return _buildGuidePage(
      icon: Icons.layers,
      color: AppTheme.transportColor,
      title: 'Camadas do Mapa',
      description: 'Ative informações adicionais do GeoServer.',
      features: [
        '🏗️ Obras públicas em andamento',
        '🚧 Interdições de ruas',
        '🏞️ Áreas verdes e parques',
        '📊 Dados geoespaciais',
        '🗺️ Mapas temáticos',
      ],
      tips: [
        'Toque no ícone de camadas (☰) no mapa',
        'Ative/desative quantas quiser',
        'Algumas camadas têm informações ao tocar',
      ],
    );
  }

  /// Página 7: Dicas
  Widget _buildTipsPage() {
    return _buildGuidePage(
      icon: Icons.lightbulb,
      color: AppTheme.warning,
      title: 'Dicas e Truques',
      description: 'Aproveite ao máximo o mapa!',
      features: [
        '💡 Busque por nome ou endereço',
        '📍 Salve locais como favoritos',
        '🔔 Ative notificações de proximidade',
        '📤 Compartilhe locais com amigos',
        '🌙 Modo escuro: mais confortável à noite',
      ],
      tips: [
        'Mantenha o GPS ativado para melhor precisão',
        'Use Wi-Fi para carregar o mapa mais rápido',
        'Limpe o cache se o mapa ficar lento',
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
        children: List.generate(7, (index) {
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
          if (_currentPage > 0 && _currentPage < 6) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_currentPage < 6) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(_currentPage < 6 ? Icons.arrow_forward : Icons.check),
              label: Text(_currentPage < 6 ? 'Próximo' : 'Concluir'),
            ),
          ),
        ],
      ),
    );
  }
}