import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../main.dart';

/// Tela do menu principal
/// 
/// Exibe as 6 categorias de serviços: Saúde, Educação,
/// Comunidade, Segurança, Transporte e Cultura & Lazer
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /// Carrega categorias do banco de dados
  Future<void> _loadCategories() async {
    final dbHelper = DatabaseHelper();
    final categories = await dbHelper.getCategories();
    
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'emergency':
                  Navigator.of(context).pushNamed(AppConstants.routeEmergency);
                  break;
                case 'news':
                  Navigator.of(context).pushNamed(AppConstants.routeNews);
                  break;
                case 'city-guide':
                  Navigator.of(context).pushNamed(AppConstants.routeCityGuide);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'emergency',
                child: Row(
                  children: [
                    Icon(Icons.emergency, color: Color(0xFFDC2626)),
                    SizedBox(width: 12),
                    Text('Emergências'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'news',
                child: Row(
                  children: [
                    Icon(Icons.newspaper, color: Color(0xFF2563EB)),
                    SizedBox(width: 12),
                    Text('Notícias'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'city-guide',
                child: Row(
                  children: [
                    Icon(Icons.location_city, color: Color(0xFF059669)),
                    SizedBox(width: 12),
                    Text('Guia da Cidade'),
                  ],
                ),
              ),
            ],
          ),
          // Botão de perfil/login
          IconButton(
            icon: Icon(
              userProvider.isLoggedIn ? Icons.person : Icons.person_outline,
            ),
            onPressed: () {
              if (userProvider.isLoggedIn) {
                Navigator.of(context).pushNamed(AppConstants.routeProfile);
              } else {
                Navigator.of(context).pushNamed(AppConstants.routeLogin);
              }
            },
          ),
        ],
      ),
    body: SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com boas-vindas
                  _buildHeader(userProvider),
                  
                  // Seção de serviços adicionais
                  _buildAdditionalServices(),

                  // Grid de categorias
                  _buildCategoriesGrid(),
                  
                  const SizedBox(height: 24),
                  
                  // Seção de acesso rápido
                  _buildQuickAccess(),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppConstants.routeMap);
        },
        child: const Icon(Icons.map),
      ),
    );
  }

  /// Constrói header com boas-vindas
  Widget _buildHeader(UserProvider userProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userProvider.isLoggedIn
                ? 'Olá, ${userProvider.userName?.split(' ')[0] ?? 'Usuário'}!'
                : 'Olá, Visitante!',
            style: const TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore os serviços de Guarulhos',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói seção de serviços adicionais
  Widget _buildAdditionalServices() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Serviços Adicionais',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildServiceCard(
                  'Emergências',
                  Icons.emergency,
                  const Color(0xFFDC2626),
                  () => Navigator.of(context).pushNamed(AppConstants.routeEmergency),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildServiceCard(
                  'Notícias',
                  Icons.newspaper,
                  const Color(0xFF2563EB),
                  () => Navigator.of(context).pushNamed(AppConstants.routeNews),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildServiceCard(
                  'Guia da Cidade',
                  Icons.location_city,
                  const Color(0xFF059669),
                  () => Navigator.of(context).pushNamed(AppConstants.routeCityGuide),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(), // Espaço vazio para manter layout
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói grid de categorias
  Widget _buildCategoriesGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categorias',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ],
      ),
    );
  }

  /// Constrói card de categoria
  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final categoryId = category['category_id'] as int;
    final categoryName = category['name'] as String;
    final categoryIcon = category['icon'] as String;
    final color = AppTheme.getCategoryColor(categoryId);
    final icon = AppTheme.getCategoryIcon(categoryIcon);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppConstants.routeCategory,
            arguments: {
              'categoryId': categoryId,
              'categoryName': categoryName,
            },
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                categoryName,
                style: const TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói seção de acesso rápido
  Widget _buildQuickAccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acesso Rápido',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickAccessCard(
            icon: Icons.map_outlined,
            title: 'Guia do Mapa',
            description: 'Aprenda a usar o mapa interativo',
            onTap: () {
              // Navegar para guia do mapa
              _showComingSoon();
            },
          ),
          const SizedBox(height: 12),
          _buildQuickAccessCard(
            icon: Icons.menu_book_outlined,
            title: 'Guia de Serviços',
            description: 'Veja todos os serviços disponíveis',
            onTap: () {
              Navigator.of(context).pushNamed(AppConstants.routeServiceGuide);
            },
          ),
          const SizedBox(height: 12),
          _buildQuickAccessCard(
            icon: Icons.person_outline,
            title: 'Guia do Perfil',
            description: 'Configure suas preferências',
            onTap: () {
              // Navegar para guia do perfil
              _showComingSoon();
            },
          ),
        ],
      ),
    );
  }

  /// Constrói card de acesso rápido
  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
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
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mostra mensagem de "Em breve"
  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em desenvolvimento'),
        backgroundColor: AppTheme.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}