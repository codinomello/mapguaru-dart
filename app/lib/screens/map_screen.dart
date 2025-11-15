import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../database/database_helper.dart';
import '../models/service_unit_model.dart';
import '../models/custom_marker_model.dart';
import '../services/geonetwork_service.dart';
import '../services/route_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../main.dart';

/// Tela do mapa interativo com suporte a camadas WMS, marcadores personalizados e rotas
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  
  // Unidades de serviço
  List<ServiceUnit> _allUnits = [];
  List<ServiceUnit> _filteredUnits = [];
  
  // Marcadores personalizados
  List<CustomMarker> _customMarkers = [];
  
  // Camadas WMS
  List<Map<String, dynamic>> _wmsLayers = [];
  List<String> _activeLayers = [];
  
  // Rotas
  List<LatLng> _routePoints = [];
  bool _showingRoute = false;
  
  // Estados
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool _isLoadingLayers = false;
  bool _isLoadingRoute = false;
  bool _addMarkerMode = false;
  bool _showCustomMarkers = true;
  
  // Seleções
  ServiceUnit? _selectedUnit;
  CustomMarker? _selectedCustomMarker;
  // UserProvider listener
  UserProvider? _userProviderRef;
  VoidCallback? _userListener;
  
  // Localização
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadUnits();
    _loadWMSLayers();
    _getCurrentLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _selectedCategoryId = args['categoryId'] as int?;
      final units = args['units'] as List<ServiceUnit>?;
      final centerOnFirst = args['centerOnFirst'] as bool? ?? false;
      _addMarkerMode = args['addMarkerMode'] as bool? ?? false;

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

      // Centralizar em marcador personalizado
      final customMarkerData = args['customMarker'] as Map<String, dynamic>?;
      if (customMarkerData != null) {
        final marker = CustomMarker.fromMap(customMarkerData);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(
            LatLng(marker.latitude, marker.longitude),
            AppConstants.detailMapZoom,
          );
          setState(() => _selectedCustomMarker = marker);
        });
      }
    }

    // Listen to user login/logout to load/clear custom markers dynamically
    final userProvider = Provider.of<UserProvider>(context);
    if (_userProviderRef != userProvider) {
      // remove old listener
      if (_userProviderRef != null && _userListener != null) {
        _userProviderRef!.removeListener(_userListener!);
      }

      _userProviderRef = userProvider;
      _userListener = () {
        if (mounted) {
          if (_userProviderRef!.isLoggedIn) {
            _loadCustomMarkers();
          } else {
            setState(() => _customMarkers = []);
          }
        }
      };
      _userProviderRef!.addListener(_userListener!);
    }
  }

  @override
  void dispose() {
    if (_userProviderRef != null && _userListener != null) {
      _userProviderRef!.removeListener(_userListener!);
    }
    super.dispose();
  }

  /// Obtém localização atual do usuário
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ Serviço de localização desabilitado');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('⚠️ Permissão de localização negada');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ Permissão de localização negada permanentemente');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      
      debugPrint('✅ Localização obtida: ${_currentLocation}');
    } catch (e) {
      debugPrint('❌ Erro ao obter localização: $e');
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

    // Carrega marcadores personalizados
    _loadCustomMarkers();
  }

  /// Carrega marcadores personalizados do usuário
  Future<void> _loadCustomMarkers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      if (!userProvider.isLoggedIn) {
        // clear markers when not logged
        if (_customMarkers.isNotEmpty) setState(() => _customMarkers = []);
        debugPrint('📍 User not logged in — cleared custom markers');
        return;
      }

      final dbHelper = DatabaseHelper();
      final markersData = await dbHelper.getUserCustomMarkers(userProvider.userId!);

      final loaded = markersData
          .map((data) {
            try {
              return CustomMarker.fromMap(data);
            } catch (e) {
              debugPrint('⚠️ Skipping invalid custom marker data: $e — $data');
              return null;
            }
          })
          .whereType<CustomMarker>()
          .toList();

      setState(() {
        _customMarkers = loaded;
      });

      debugPrint('📍 Loaded ${_customMarkers.length} custom markers for user ${userProvider.userId}');
    } catch (e, st) {
      debugPrint('❌ Error loading custom markers: $e\n$st');
      // keep previous markers if any, but ensure UI not blocked
    }
  }

  /// Carrega camadas WMS disponíveis
  Future<void> _loadWMSLayers() async {
    setState(() => _isLoadingLayers = true);

    try {
      final layers = await GeoNetworkService.getWMSLayers();
      
      const specificMetadataId = '54c282b4-12de-4dfa-9d1d-ee57cf6c52a1';
      final specificLayer = await GeoNetworkService.getWMSLayerById(specificMetadataId);

      if (specificLayer != null) {
        final layerExists = layers.any((l) => l['name'] == specificLayer['name']);
        if (!layerExists) {
          layers.add(specificLayer);
        }
        if (!_activeLayers.contains(specificLayer['name'])) {
          _activeLayers.add(specificLayer['name'] as String);
        }
      }

      setState(() {
        _wmsLayers = layers;
        _isLoadingLayers = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar camadas WMS: $e');
      setState(() => _isLoadingLayers = false);
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
      _selectedCustomMarker = null;
    });
  }

  /// Centraliza no marcador personalizado
  void _centerOnCustomMarker(CustomMarker marker) {
    _mapController.move(
      LatLng(marker.latitude, marker.longitude),
      AppConstants.detailMapZoom,
    );
    setState(() {
      _selectedCustomMarker = marker;
      _selectedUnit = null;
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

  /// Calcula rota até o destino
  Future<void> _calculateRoute(double destLat, double destLng, String destName) async {
    if (_currentLocation == null) {
      // Tentativa automática de obter localização caso ainda não tenha sido
      // obtida (pode solicitar permissão ao usuário).
      await _getCurrentLocation();

      // Se após a tentativa ainda não houver localização, informamos o usuário
      // e interrompemos o fluxo.
      if (_currentLocation == null) {
        _showSnackBar('Ative a localização para calcular rotas');
        return;
      }
    }

    setState(() {
      _isLoadingRoute = true;
      _showingRoute = false;
    });

    try {
      final routeData = await RouteService.calculateRoute(
        start: _currentLocation!,
        end: LatLng(destLat, destLng),
        profile: 'foot-walking', // ou 'driving-car'
      );

      if (routeData != null && mounted) {
        final points = RouteService.extractRoutePoints(routeData);
        final info = RouteService.extractRouteInfo(routeData);

        setState(() {
          _routePoints = points;
          _showingRoute = true;
          _isLoadingRoute = false;
        });

        // Ajustar zoom para mostrar toda a rota
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(_routePoints),
            padding: const EdgeInsets.all(50),
          ),
        );

        _showSnackBar(
          'Rota calculada: ${info['distance'].toStringAsFixed(1)} km, '
          '${info['duration'].toStringAsFixed(0)} min',
          isError: false,
        );
      } else {
        _showSnackBar('Não foi possível calcular a rota');
        setState(() => _isLoadingRoute = false);
      }
    } catch (e) {
      debugPrint('Erro ao calcular rota: $e');
      _showSnackBar('Erro ao calcular rota');
      setState(() => _isLoadingRoute = false);
    }
  }

  /// Limpa rota do mapa
  void _clearRoute() {
    setState(() {
      _routePoints = [];
      _showingRoute = false;
    });
  }

  /// Mostra dialog para adicionar marcador
  void _showAddMarkerDialog(LatLng position) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      _showSnackBar('Faça login para adicionar marcadores personalizados');
      return;
    }

    final nameController = TextEditingController();
    final descController = TextEditingController();
    String? selectedCategory = 'pessoal';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Marcador Personalizado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  hintText: 'Ex: Minha Casa',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Adicione detalhes',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                ),
                items: CustomMarker.categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id'] as String,
                    child: Row(
                      children: [
                        Icon(
                          _getIconData(cat['icon'] as String),
                          size: 20,
                          color: _parseColor(cat['color'] as String),
                        ),
                        const SizedBox(width: 8),
                        Text(cat['name'] as String),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => selectedCategory = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                _showSnackBar('Digite um nome para o marcador');
                return;
              }

              final marker = CustomMarker(
                userId: userProvider.userId!,
                name: nameController.text.trim(),
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                latitude: position.latitude,
                longitude: position.longitude,
                category: selectedCategory,
                createdAt: DateTime.now(),
              );

              final dbHelper = DatabaseHelper();
              await dbHelper.addCustomMarker(marker.toMap());

              Navigator.pop(context);

              _showSnackBar('Marcador adicionado com sucesso!', isError: false);

              // Recarregar marcadores
              _loadCustomMarkers();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_addMarkerMode ? 'Adicionar Marcador' : 'Mapa de Serviços'),
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
          if (!_addMarkerMode)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterBottomSheet,
              tooltip: 'Filtrar categorias',
            ),
          // Botão de marcadores personalizados
          if (!_addMarkerMode)
            IconButton(
              icon: Icon(
                _showCustomMarkers ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => _showCustomMarkers = !_showCustomMarkers);
              },
              tooltip: 'Marcadores personalizados',
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
                    onLongPress: _addMarkerMode
                        ? (tapPosition, latLng) => _showAddMarkerDialog(latLng)
                        : null,
                  ),
                  children: [
                    // Base Layer - OpenStreetMap
                    TileLayer(
                      urlTemplate: AppConstants.osmTileUrl,
                      userAgentPackageName: 'com.mapguaru.app',
                    ),

                    // Camadas WMS ativas
                    ..._buildWMSLayers(),

                    // Camada de rota
                    if (_showingRoute)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 5,
                            color: AppTheme.primaryColor,
                            borderStrokeWidth: 2,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),

                    // Marcadores das unidades de serviço
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

                    // Marcadores personalizados
                    if (_showCustomMarkers)
                      MarkerLayer(
                        markers: _customMarkers.map((marker) {
                          final categoryInfo = CustomMarker.getCategoryInfo(marker.category);
                          final color = categoryInfo != null
                              ? _parseColor(categoryInfo['color'] as String)
                              : AppTheme.accentColor;

                          return Marker(
                            point: LatLng(marker.latitude, marker.longitude),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => _centerOnCustomMarker(marker),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  categoryInfo != null
                                      ? _getIconData(categoryInfo['icon'] as String)
                                      : Icons.star,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    // Marcador de localização atual
                    if (_currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation!,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Botões flutuantes (movidos para dentro do Stack para controlar z-order)
                Positioned(
                  right: 16,
                  bottom: 16 + MediaQuery.of(context).padding.bottom,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão centralizar na localização
                      if (_currentLocation != null && !_addMarkerMode)
                        FloatingActionButton.small(
                          heroTag: 'location',
                          onPressed: () {
                            _mapController.move(
                              _currentLocation!,
                              15.0,
                            );
                          },
                          child: const Icon(Icons.my_location),
                        ),
                      if (_currentLocation != null && !_addMarkerMode)
                        const SizedBox(height: 8),

                      // Botão centralizar em Guarulhos
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
                        child: const Icon(Icons.home),
                      ),
                      const SizedBox(height: 8),

                      // Botão lista
                      if (!_addMarkerMode)
                        FloatingActionButton(
                          heroTag: 'list',
                          onPressed: _showUnitsList,
                          child: const Icon(Icons.list),
                        ),
                    ],
                  ),
                ),

                // Card de unidade selecionada
                if (_selectedUnit != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                    child: _buildSelectedUnitCard(_selectedUnit!),
                  ),

                // Card de marcador personalizado selecionado
                if (_selectedCustomMarker != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                    child: _buildSelectedCustomMarkerCard(_selectedCustomMarker!),
                  ),

                // Contador de unidades
                if (!_addMarkerMode)
                  Positioned(
                    top: 16 + MediaQuery.of(context).padding.top,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildUnitsCounter(),
                    ),
                  ),

                // Indicador de modo adicionar
                if (_addMarkerMode)
                  Positioned(
                    top: 16 + MediaQuery.of(context).padding.top,
                    left: 16,
                    right: 16,
                    child: Card(
                      color: AppTheme.warning,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.touch_app, color: Colors.white),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Toque longo no mapa para adicionar marcador',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Loading de rota
                if (_isLoadingRoute)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Calculando rota...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      
    );
  }

  /// Constrói camadas WMS ativas
  List<Widget> _buildWMSLayers() {
    return _activeLayers.map((layerName) {
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

  /// Contador de unidades
  Widget _buildUnitsCounter() {
    final totalCount = _filteredUnits.length + (_showCustomMarkers ? _customMarkers.length : 0);
    
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
              '$totalCount ${totalCount == 1 ? 'local' : 'locais'}',
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
                    size: 20,
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
                    setState(() => _selectedUnit = null);
                    _clearRoute();
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showingRoute
                        ? _clearRoute
                        : () => _calculateRoute(
                              unit.latitude,
                              unit.longitude,
                              unit.name,
                            ),
                    icon: Icon(_showingRoute ? Icons.close : Icons.directions),
                    label: Text(_showingRoute ? 'Limpar Rota' : 'Traçar rota'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _showingRoute ? AppTheme.error : AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card de marcador personalizado selecionado
  Widget _buildSelectedCustomMarkerCard(CustomMarker marker) {
    final categoryInfo = CustomMarker.getCategoryInfo(marker.category);
    final color = categoryInfo != null
        ? _parseColor(categoryInfo['color'] as String)
        : AppTheme.accentColor;

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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    categoryInfo != null
                        ? _getIconData(categoryInfo['icon'] as String)
                        : Icons.star,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marker.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (marker.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          marker.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() => _selectedCustomMarker = null);
                    _clearRoute();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showingRoute
                        ? _clearRoute
                        : () => _calculateRoute(
                              marker.latitude,
                              marker.longitude,
                              marker.name,
                            ),
                    icon: Icon(_showingRoute ? Icons.close : Icons.directions),
                    label: Text(_showingRoute ? 'Limpar Rota' : 'Traçar Rota'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _showingRoute ? AppTheme.error : color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
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

  /// Bottom sheet de filtros de categoria
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Filtrar por Categoria',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      // close button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildFilterOption(
                        'Todas as Categorias',
                        null,
                        Icons.grid_view_rounded,
                      ),
                      const Divider(),
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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