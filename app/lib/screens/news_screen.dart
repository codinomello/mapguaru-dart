import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/news_service.dart';
import '../utils/theme.dart';

/// Tela de feed de notícias de Guarulhos
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<NewsItem> _allNews = [];
  List<NewsItem> _filteredNews = [];
  NewsCategory _selectedCategory = NewsCategory.all;
  String _searchQuery = '';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  /// Carrega notícias
  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final news = await NewsService.fetchNews();
      
      setState(() {
        _allNews = news;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  /// Aplica filtros
  void _applyFilters() {
    var news = _allNews;
    
    // Filtra por categoria
    if (_selectedCategory != NewsCategory.all) {
      news = NewsService.filterByCategory(news, _selectedCategory);
    }
    
    // Filtra por busca
    if (_searchQuery.isNotEmpty) {
      news = NewsService.searchNews(news, _searchQuery);
    }
    
    setState(() {
      _filteredNews = news;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notícias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNews,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Barra de busca
          _buildSearchBar(),
          
          // Filtros de categoria
          _buildCategoryFilters(),
          
          const Divider(height: 1),
          
          // Lista de notícias
          Expanded(
            child: _buildNewsList(),
          ),
        ],
      ),
    );
  }

  /// Header com informações
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.newspaper,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notícias de Guarulhos',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Fique por dentro do que acontece na cidade',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 12,
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

  /// Barra de busca
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applyFilters();
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar notícias...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  /// Filtros de categoria
  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: NewsCategory.values.map((category) {
          return _buildCategoryChip(category);
        }).toList(),
      ),
    );
  }

  /// Chip de categoria
  Widget _buildCategoryChip(NewsCategory category) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 16),
            const SizedBox(width: 4),
            Text(category.name),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
            _applyFilters();
          });
        },
        selectedColor: category.color.withOpacity(0.2),
        checkmarkColor: category.color,
      ),
    );
  }

  /// Lista de notícias
  Widget _buildNewsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_filteredNews.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredNews.length,
        itemBuilder: (context, index) {
          return _buildNewsCard(_filteredNews[index]);
        },
      ),
    );
  }

  /// Card de notícia
  Widget _buildNewsCard(NewsItem news) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openNews(news),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem (se disponível)
            if (news.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  news.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoria e data
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: news.category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              news.category.icon,
                              size: 12,
                              color: news.category.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              news.category.name,
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: news.category.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        news.timeAgo,
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Título
                  Text(
                    news.title,
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Descrição
                  Text(
                    news.description,
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Botão "Ler mais"
                  Row(
                    children: [
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _openNews(news),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Ler mais'),
                        style: TextButton.styleFrom(
                          foregroundColor: news.category.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma notícia encontrada',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tente buscar por outro termo ou categoria',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Estado de erro
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar notícias',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verifique sua conexão e tente novamente',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Abre notícia completa
  Future<void> _openNews(NewsItem news) async {
    if (news.link != null) {
      try {
        final uri = Uri.parse(news.link!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir a notícia'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } else {
      // Mostra detalhes em um bottom sheet
      _showNewsDetails(news);
    }
  }

  /// Mostra detalhes da notícia
  void _showNewsDetails(NewsItem news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Categoria
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: news.category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        news.category.icon,
                        size: 16,
                        color: news.category.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        news.category.name,
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: news.category.color,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Título
                Text(
                  news.title,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Data
                Text(
                  news.timeAgo,
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Descrição completa
                Text(
                  news.description,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}