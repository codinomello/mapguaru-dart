import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../main.dart';

/// Tela de detalhes de uma categoria
/// 
/// Exibe lista de unidades de serviço da categoria selecionada
/// com opção de visualização em mapa
class CategoryDetailScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<ServiceUnit> _units = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  /// Carrega unidades da categoria
  Future<void> _loadUnits() async {
    final dbHelper = DatabaseHelper();
    final unitsData = await dbHelper.getServiceUnitsByCategory(widget.categoryId);
    
    setState(() {
      _units = unitsData.map((data) => ServiceUnit.fromMap(data)).toList();
      _isLoading = false;
    });
  }

  /// Filtra unidades por busca
  List<ServiceUnit> get _filteredUnits {
    if (_searchQuery.isEmpty) return _units;
    
    return _units.where((unit) {
      return unit.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (unit.neighborhood?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getCategoryColor(widget.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: color,
      ),
      body: Column(
        children: [
          // Barra de busca
          _buildSearchBar(),
          
          // Lista de unidades
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUnits.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredUnits.length,
                        itemBuilder: (context, index) {
                          return _buildUnitCard(_filteredUnits[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(
            AppConstants.routeMap,
            arguments: {
              'categoryId': widget.categoryId,
              'units': _units,
            },
          );
        },
        icon: const Icon(Icons.map),
        label: const Text('Ver no Mapa'),
        backgroundColor: color,
      ),
    );
  }

  /// Constrói barra de busca
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou bairro...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppTheme.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Constrói card de unidade
  Widget _buildUnitCard(ServiceUnit unit) {
    final userProvider = Provider.of<UserProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = userProvider.isLoggedIn 
        ? favoritesProvider.isFavorite(unit.unitId!)
        : false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: InkWell(
        onTap: () => _showUnitDetails(unit),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícone
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.getCategoryColor(widget.categoryId)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.place,
                      color: AppTheme.getCategoryColor(widget.categoryId),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Nome e endereço
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.name,
                          style: const TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          unit.neighborhood ?? unit.address,
                          style: const TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Botão favorito
                  if (userProvider.isLoggedIn)
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : AppTheme.textLight,
                      ),
                      onPressed: () async {
                        await favoritesProvider.toggleFavorite(
                          userProvider.userId!,
                          unit.unitId!,
                        );
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite
                                    ? AppConstants.successFavoriteRemoved
                                    : AppConstants.successFavoriteAdded,
                              ),
                              backgroundColor: AppTheme.success,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
              
              if (unit.openingHours != null || unit.phone != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Horário e telefone
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (unit.openingHours != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            unit.openingHours!,
                            style: const TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    if (unit.phone != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            unit.phone!,
                            style: const TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Mostra detalhes completos da unidade
  void _showUnitDetails(ServiceUnit unit) {
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
                      color: AppTheme.textLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Nome
                Text(
                  unit.name,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                
                if (unit.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    unit.description!,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Endereço
                _buildDetailItem(
                  Icons.location_on,
                  'Endereço',
                  unit.fullAddress,
                ),
                
                if (unit.openingHours != null)
                  _buildDetailItem(
                    Icons.access_time,
                    'Horário',
                    unit.openingHours!,
                  ),
                
                if (unit.phone != null)
                  _buildDetailItem(
                    Icons.phone,
                    'Telefone',
                    unit.phone!,
                  ),
                
                if (unit.email != null)
                  _buildDetailItem(
                    Icons.email,
                    'E-mail',
                    unit.email!,
                  ),
                
                if (unit.website != null)
                  _buildDetailItem(
                    Icons.language,
                    'Website',
                    unit.website!,
                  ),
                
                const SizedBox(height: 24),
                
                // Botões de ação
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(
                            AppConstants.routeMap,
                            arguments: {
                              'units': [unit],
                              'centerOnFirst': true,
                            },
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Ver no Mapa'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Constrói item de detalhe
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
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
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Nenhuma unidade encontrada'
                  : 'Nenhum resultado para "$_searchQuery"',
              style: const TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tente buscar por outro termo',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}