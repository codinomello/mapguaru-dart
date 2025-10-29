import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../database/database_helper.dart';
import '../models/service_unit_model.dart';
import '../services/geonetwork_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Tela do mapa interativo com suporte a camadas WMS
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<ServiceUnit> _allUnits = [];
  List<ServiceUnit> _filteredUnits = [];
  List<Map<String, dynamic>> _wmsLayers = [];
  List<String> _activeLayers = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool _isLoadingLayers = false;
  ServiceUnit? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _loadUnits();
    _loadWMSLayers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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

  /// Carrega camadas WMS disponíveis
  Future<void> _loadWMSLayers() async {
    setState(() {
      _isLoadingLayers = true;
    });

    try {
      final layers = await GeoNetworkService.getWMSLayers();
      
      // --- BLOCO DE ADIÇÃO DA CAMADA ESPECÍFICA POR ID ---
      const specificMetadataId = '54c282b4-12de-4dfa-9d1d-ee57cf6c52a1';
      final specificLayer = await GeoNetworkService.getWMSLayerById(specificMetadataId);

      if (specificLayer != null) {
        // Verifica se a camada já está na lista genérica (para evitar duplicatas)
        final layerExists = layers.any((l) => l['name'] == specificLayer['name']);
        
        if (!layerExists) {
          layers.add(specificLayer);
        }
        
        // Opcional: Ativa a camada ao iniciar
        if (!_activeLayers.contains(specificLayer['name'])) {
           _activeLayers.add(specificLayer['name'] as String);
        }
      }
      // -----------------------------------------------------

      setState(() {
        _wmsLayers = layers;
        _isLoadingLayers = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar camadas WMS: $e');
      setState(() {
        _isLoadingLayers = false;
      });
    }
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

  /// Toggle camada WMS
  void _toggleWMSLayer(String layerName) {
    setState(() {
      if (_activeLayers.contains(layerName)) {
        _activeLayers.remove(layerName);
      } else {
        _activeLayers.add(layerName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Serviços'),
        actions: [
          // Botão de camadas WMS
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.layers),
                if (_activeLayers.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_activeLayers.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showLayersBottomSheet,
            tooltip: 'Camadas do mapa',
          ),
          // Botão de filtro
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filtrar categorias',
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
                    // Base Layer - OpenStreetMap
                    TileLayer(
                      urlTemplate: AppConstants.osmTileUrl,
                      userAgentPackageName: 'com.mapguaru.app',
                    ),

                    // Camadas WMS ativas
                    ..._buildWMSLayers(),

                    // Marcadores das unidades
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
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                    child: _buildSelectedUnitCard(_selectedUnit!),
                  ),

                // Contador de unidades
                Positioned(
                  top: 16 + MediaQuery.of(context).padding.top,
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

  /// Constrói camadas WMS ativas
  List<Widget> _buildWMSLayers() {
    return _activeLayers.map((layerName) {
      // Encontra URL da camada
      final layer = _wmsLayers.firstWhere(
        (l) => l['name'] == layerName,
        orElse: () => {},
      );
      
      final baseUrl = layer['url'] as String? ?? 
          'https://geonetwork.guarulhos.sp.gov.br:8443/geoserver/wms';
      
      return TileLayer(
        wmsOptions: WMSTileLayerOptions(
          baseUrl: baseUrl,
          layers: [layerName],
          version: '1.3.0',
          format: 'image/png',
          transparent: true,
        ),
        userAgentPackageName: 'com.mapguaru.app',
      );
    }).toList();
  }

  /// Mostra bottom sheet de camadas WMS
  void _showLayersBottomSheet() {
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.layers, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Camadas do Mapa',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    if (_isLoadingLayers)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Lista de camadas
              Expanded(
                child: _wmsLayers.isEmpty && !_isLoadingLayers
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.layers_clear, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma camada disponível',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _wmsLayers.length,
                        itemBuilder: (context, index) {
                          final layer = _wmsLayers[index];
                          final layerName = layer['name'] as String;
                          final title = layer['title'] as String;
                          final description = layer['description'] as String?;
                          final isActive = _activeLayers.contains(layerName);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: CheckboxListTile(
                              value: isActive,
                              onChanged: (_) => _toggleWMSLayer(layerName),
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: description != null
                                  ? Text(
                                      description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  : null,
                              secondary: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.map,
                                  color: isActive ? Colors.white : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              // Botões de ação
              if (_wmsLayers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _activeLayers.isEmpty
                              ? null
                              : () {
                                  setState(() {
                                    _activeLayers.clear();
                                  });
                                  Navigator.pop(context);
                                },
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Limpar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.check),
                          label: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Contador de unidades
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
              '${_filteredUnits.length} ${_filteredUnits.length == 1 ? 'local' : 'locais'}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de unidade selecionada
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unit.neighborhood ?? unit.address,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
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
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unit.openingHours!,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  if (unit.phone != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unit.phone!,
                          style: const TextStyle(fontSize: 11),
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

  /// Bottom sheet de filtros de categoria
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
            Text(
              'Filtrar por Categoria',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Todas as categorias
            _buildFilterOption(
              'Todas as Categorias',
              null,
              Icons.grid_view_rounded,
            ),
            const Divider(),
            
            // Categorias específicas
            ...List.generate(6, (index) {
              final categoryId = index + 1;
              return _buildFilterOption(
                AppConstants.categoryNames[categoryId]!,
                categoryId,
                AppTheme.getCategoryIcon(
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

  /// Opção de filtro
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
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? color : null,
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

  /// Bottom sheet com lista de unidades
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Locais no Mapa',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Text(
                      '${_filteredUnits.length}',
                      style: const TextStyle(
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          unit.neighborhood ?? unit.address,
                          style: const TextStyle(fontSize: 12),
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