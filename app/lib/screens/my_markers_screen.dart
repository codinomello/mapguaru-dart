import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/custom_marker_model.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../main.dart';

/// Tela de Meus Marcadores Personalizados
class MyMarkersScreen extends StatefulWidget {
  const MyMarkersScreen({super.key});

  @override
  State<MyMarkersScreen> createState() => _MyMarkersScreenState();
}

class _MyMarkersScreenState extends State<MyMarkersScreen> {
  List<CustomMarker> _markers = [];
  String? _selectedCategory;
  bool _showOnlyFavorites = false;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isLoggedIn) {
        setState(() => _isLoading = false);
        return;
      }

      final dbHelper = DatabaseHelper();
      List<Map<String, dynamic>> markersData;

      if (_showOnlyFavorites) {
        markersData = await dbHelper.getFavoriteCustomMarkers(userProvider.userId!);
      } else if (_selectedCategory != null) {
        markersData = await dbHelper.getCustomMarkersByCategory(
          userProvider.userId!,
          _selectedCategory!,
        );
      } else {
        markersData = await dbHelper.getUserCustomMarkers(userProvider.userId!);
      }

      setState(() {
        _markers = markersData.map((data) => CustomMarker.fromMap(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar marcadores: $e');
      setState(() => _isLoading = false);
    }
  }

  List<CustomMarker> get _filteredMarkers {
    if (_searchQuery.isEmpty) return _markers;

    return _markers.where((marker) {
      final name = marker.name.toLowerCase();
      final description = marker.description?.toLowerCase() ?? '';
      final address = marker.address?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) ||
          description.contains(query) ||
          address.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (!userProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meus Marcadores')),
        body: _buildLoginRequired(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Marcadores'),
        actions: [
          IconButton(
            icon: Icon(_showOnlyFavorites ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
              _loadMarkers();
            },
            tooltip: 'Favoritos',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMarkers.isEmpty
                    ? _buildEmptyState()
                    : _buildMarkersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(
            AppConstants.routeMap,
            arguments: {'addMarkerMode': true},
          );
        },
        icon: const Icon(Icons.add_location),
        label: const Text('Adicionar Marcador'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Buscar marcador...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildCategoryChip('Todos', null, Icons.grid_view),
          ...CustomMarker.categories.map((cat) {
            return _buildCategoryChip(
              cat['name'] as String,
              cat['id'] as String,
              _getIconData(cat['icon'] as String),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? categoryId, IconData icon) {
    final isSelected = _selectedCategory == categoryId;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? categoryId : null;
          });
          _loadMarkers();
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildMarkersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredMarkers.length,
      itemBuilder: (context, index) {
        return _buildMarkerCard(_filteredMarkers[index]);
      },
    );
  }

  Widget _buildMarkerCard(CustomMarker marker) {
    final categoryInfo = CustomMarker.getCategoryInfo(marker.category);
    final color = categoryInfo != null
        ? _parseColor(categoryInfo['color'] as String)
        : AppTheme.primaryColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showMarkerDetails(marker),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryInfo != null
                      ? _getIconData(categoryInfo['icon'] as String)
                      : Icons.place,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marker.name,
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (marker.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        marker.description!,
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (marker.address != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              marker.address!,
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Botão favorito
              IconButton(
                icon: Icon(
                  marker.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: marker.isFavorite ? Colors.red : null,
                ),
                onPressed: () => _toggleFavorite(marker),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_location_alt,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _showOnlyFavorites
                  ? 'Nenhum favorito ainda'
                  : 'Nenhum marcador adicionado',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Toque longo no mapa para adicionar\nseus locais favoritos',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppConstants.routeMap,
                  arguments: {'addMarkerMode': true},
                );
              },
              icon: const Icon(Icons.add_location),
              label: const Text('Adicionar Primeiro Marcador'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Login Necessário',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Faça login para adicionar e gerenciar\nseus marcadores personalizados',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.routeLogin);
              },
              child: const Text('Fazer Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkerDetails(CustomMarker marker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final categoryInfo = CustomMarker.getCategoryInfo(marker.category);
          final color = categoryInfo != null
              ? _parseColor(categoryInfo['color'] as String)
              : AppTheme.primaryColor;

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

                // Nome e categoria
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        categoryInfo != null
                            ? _getIconData(categoryInfo['icon'] as String)
                            : Icons.place,
                        color: color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            marker.name,
                            style: const TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (categoryInfo != null)
                            Text(
                              categoryInfo['name'] as String,
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                fontSize: 14,
                                color: color,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (marker.description != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    marker.description!,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],

                if (marker.address != null) ...[
                  const SizedBox(height: 24),
                  _buildDetailRow(Icons.location_on, 'Endereço', marker.address!),
                ],

                const SizedBox(height: 24),

                // Botões de ação
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editMarker(marker),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(
                            AppConstants.routeMap,
                            arguments: {
                              'customMarker': marker.toMap(),
                              'centerOnMarker': true,
                            },
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Ver no Mapa'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(marker),
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite(CustomMarker marker) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.toggleCustomMarkerFavorite(marker.markerId!);
      _loadMarkers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              marker.isFavorite
                  ? 'Removido dos favoritos'
                  : 'Adicionado aos favoritos',
            ),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao alternar favorito: $e');
    }
  }

  void _editMarker(CustomMarker marker) {
    Navigator.pop(context);
    // TODO: Implementar tela de edição
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _confirmDelete(CustomMarker marker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir "${marker.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Fecha dialog
              Navigator.pop(context); // Fecha bottom sheet
              await _deleteMarker(marker);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMarker(CustomMarker marker) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.deleteCustomMarker(marker.markerId!);
      _loadMarkers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marcador excluído com sucesso'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao excluir marcador: $e');
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'local_hospital':
        return Icons.local_hospital;
      default:
        return Icons.place;
    }
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
  }
}