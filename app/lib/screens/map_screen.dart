import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../database/database_helper.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Tela do mapa interativo
///
/// Exibe mapa com OpenStreetMap mostrando as unidades de serviço
/// com marcadores coloridos por categoria
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<ServiceUnit> _allUnits = [];
  List<ServiceUnit> _filteredUnits = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  ServiceUnit? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Receber argumentos da navegação
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _selectedCategoryId = args['categoryId'] as int?;
      final units = args['units'] as List<ServiceUnit>?;
      final centerOnFirst = args['centerOnFirst'] as bool? ?? false;

      if (units != null) {
        _filteredUnits = units;

        if (centerOnFirst && units.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(
              LatLng(units.first.latitude, units.first.longitude),
              AppConstants.detailMapZoom,
            );
          });
        }
      }
    }
  }

  /// Carrega todas as unidades
  Future<void> _loadUnits() async {
    final dbHelper = DatabaseHelper();
    final unitsData = await dbHelper.getAllServiceUnits();

    setState(() {
      _allUnits = unitsData.map((data) => ServiceUnit.fromMap(data)).toList();
      if (_filteredUnits.isEmpty) {
        _filteredUnits = _allUnits;
      }
      _isLoading = false;
    });
  }

  /// Filtra unidades por categoria
  void _filterByCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      if (categoryId == null) {
        _filteredUnits = _allUnits;
      } else {
        _filteredUnits = _allUnits
            .where((unit) => unit.category == categoryId)
            .toList();
      }
      _selectedUnit = null;
    });
  }

  /// Centraliza mapa em uma unidade
  void _centerOnUnit(ServiceUnit unit) {
    _mapController.move(
      LatLng(unit.latitude, unit.longitude),
      AppConstants.detailMapZoom,
    );
    setState(() {
      _selectedUnit = unit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Serviços'),
        actions: [
          // Botão de filtro
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Mapa
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      AppConstants.guarulhosCenterLat,
                      AppConstants.guarulhosCenterLng,
                    ),
                    initialZoom: AppConstants.defaultMapZoom,
                    minZoom: 11.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    // Tile Layer (OpenStreetMap)
                    TileLayer(
                      urlTemplate: AppConstants.osmTileUrl,
                      userAgentPackageName: 'com.mapguaru.app',
                    ),

                    // Marcadores
                    MarkerLayer(
                      markers: _filteredUnits.map((unit) {
                        return Marker(
                          point: LatLng(unit.latitude, unit.longitude),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _centerOnUnit(unit),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.getCategoryColor(unit.category),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.place,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Card de unidade selecionada
                if (_selectedUnit != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _buildSelectedUnitCard(_selectedUnit!),
                  ),

                // Contador de unidades
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: _buildUnitsCounter(),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botão centralizar
          FloatingActionButton.small(
            heroTag: 'center',
            onPressed: () {
              _mapController.move(
                const LatLng(
                  AppConstants.guarulhosCenterLat,
                  AppConstants.guarulhosCenterLng,
                ),
                AppConstants.defaultMapZoom,
              );
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),

          // Botão lista
          FloatingActionButton(
            heroTag: 'list',
            onPressed: _showUnitsList,
            child: const Icon(Icons.list),
          ),
        ],
      ),
    );
  }

  /// Constrói contador de unidades
  Widget _buildUnitsCounter() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.place_outlined,
              size: 18,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              '${_filteredUnits.length} ${_filteredUnits.length == 1 ? 'local encontrado' : 'locais encontrados'}',
              style: const TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói card de unidade selecionada
  Widget _buildSelectedUnitCard(ServiceUnit unit) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.getCategoryColor(unit.category)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.place,
                    color: AppTheme.getCategoryColor(unit.category),
                  ),
                ),
                const SizedBox(width: 12),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unit.neighborhood ?? unit.address,
                        style: const TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedUnit = null;
                    });
                  },
                ),
              ],
            ),
            if (unit.openingHours != null || unit.phone != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
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
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unit.openingHours!,
                          style: const TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 11,
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
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unit.phone!,
                          style: const TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 11,
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
    );
  }

  /// Mostra bottom sheet de filtros
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar por Categoria',
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Opção: Todas
            _buildFilterOption(
              'Todas as Categorias',
              null,
              Icons.grid_view_rounded,
            ),
            const Divider(),
            
            // Opções de categorias
            ...List.generate(6, (index) {
              final categoryId = index + 1;
              return _buildFilterOption(
                AppConstants.categoryNames[categoryId]!,
                categoryId,
                AppTheme.getCategoryIcon(
                  // Mapeia o categoryId para o nome do ícone
                  {
                    1: 'health', 2: 'education', 3: 'community',
                    4: 'security', 5: 'transport', 6: 'culture'
                  }[categoryId]!,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Constrói opção de filtro
  Widget _buildFilterOption(String title, int? categoryId, IconData icon) {
    final isSelected = _selectedCategoryId == categoryId;
    final color = categoryId != null 
        ? AppTheme.getCategoryColor(categoryId)
        : AppTheme.primaryColor;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? color : AppTheme.textPrimary,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: color)
          : null,
      onTap: () {
        _filterByCategory(categoryId);
        Navigator.pop(context);
      },
    );
  }

  /// Mostra lista de unidades
  void _showUnitsList() {
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
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Título
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      'Locais no Mapa',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_filteredUnits.length}',
                      style: const TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Lista
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredUnits.length,
                  itemBuilder: (context, index) {
                    final unit = _filteredUnits[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.getCategoryColor(unit.category)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.place,
                            color: AppTheme.getCategoryColor(unit.category),
                          ),
                        ),
                        title: Text(
                          unit.name,
                          style: const TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          unit.neighborhood ?? unit.address,
                          style: const TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context);
                          _centerOnUnit(unit);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}