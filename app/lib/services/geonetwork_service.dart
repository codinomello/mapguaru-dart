import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Serviço para integração com o GeoNetwork de Guarulhos
/// 
/// Conecta-se à API REST do GeoNetwork 4.x para buscar metadados
/// e camadas WMS/WFS de serviços públicos da cidade
class GeoNetworkService {
  static const String _baseUrl = 'https://geonetwork.guarulhos.sp.gov.br:8443';
  static const String _geoserverUrl = '$_baseUrl/geoserver';
  static const String _geonetworkUrl = '$_baseUrl/geonetwork';
  
  /// Busca metadados no catálogo usando a API REST
  /// 
  /// [query] - Termo de busca (padrão: '*' para todos)
  /// [from] - Índice inicial para paginação
  /// [size] - Quantidade de resultados por página
  static Future<List<Map<String, dynamic>>> searchMetadata({
    String? query,
    int from = 0,
    int size = 100,
  }) async {
    try {
      debugPrint('🔍 Buscando metadados: "${query ?? '*'}"');
      
      final url = '$_geonetworkUrl/srv/api/search/records/_search';
      
      final requestBody = {
        'from': from,
        'size': size,
        'query': {
          'query_string': {
            'query': query ?? '*',
            'default_operator': 'AND',
          }
        },
        'sort': [{'resourceTitle': 'asc'}],
      };
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 20));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hits = data['hits']?['hits'] as List?;
        
        if (hits != null && hits.isNotEmpty) {
          debugPrint('✅ ${hits.length} metadados encontrados');
          return hits.map((hit) => hit['_source'] as Map<String, dynamic>).toList();
        }
      } else {
        debugPrint('⚠️ Status da busca: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('❌ Erro ao buscar metadados: $e');
      debugPrint('Stack: $stack');
    }
    
    return [];
  }
  
  /// Busca metadado específico por UUID
  /// 
  /// [metadataId] - UUID do metadado no GeoNetwork
  static Future<Map<String, dynamic>?> getMetadataById(String metadataId) async {
    try {
      debugPrint('🔎 Buscando metadado: $metadataId');
      
      final url = '$_geonetworkUrl/srv/api/records/$metadataId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        debugPrint('✅ Metadado encontrado');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('⚠️ Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Erro: $e');
    }
    
    return null;
  }
  
  /// Busca camada WMS específica por ID de metadado
  /// 
  /// [metadataId] - UUID do metadado no GeoNetwork
  /// 
  /// Retorna informações da camada WMS se encontrada
  static Future<Map<String, dynamic>?> getWMSLayerById(String metadataId) async {
    try {
      debugPrint('🗺️ Buscando camada WMS por ID: $metadataId');
      
      final metadata = await getMetadataById(metadataId);
      if (metadata == null) return null;
      
      // Tenta extrair link WMS do metadado
      final links = metadata['link'] as List?;
      if (links != null) {
        for (var link in links) {
          final protocol = link['protocol']?.toString() ?? '';
          
          if (protocol.toUpperCase().contains('WMS')) {
            final layerName = link['name']?.toString();
            
            if (layerName != null && layerName.isNotEmpty) {
              final title = _extractField(metadata, ['resourceTitle', 'title']) ?? layerName;
              final description = _extractField(metadata, ['resourceAbstract', 'abstract']);
              
              debugPrint('✅ Camada WMS encontrada: $title');
              
              return {
                'name': layerName,
                'title': title,
                'description': description,
                'url': link['url']?.toString() ?? '$_geoserverUrl/wms',
                'metadata_id': metadataId,
              };
            }
          }
        }
      }
      
      debugPrint('⚠️ Nenhuma camada WMS encontrada no metadado');
    } catch (e) {
      debugPrint('❌ Erro ao buscar camada por ID: $e');
    }
    
    return null;
  }
  
  /// Extrai camadas WMS dos metadados encontrados
  static Future<List<Map<String, dynamic>>> getWMSLayers() async {
    try {
      debugPrint('🗺️ Buscando camadas WMS...');
      
      // Busca metadados com protocolo WMS
      final metadata = await searchMetadata(
        query: 'protocol:OGC\\:WMS OR protocol:WMS',
      );
      
      final layers = <Map<String, dynamic>>[];
      
      for (var record in metadata) {
        try {
          final links = record['link'] as List?;
          if (links == null) continue;
          
          for (var link in links) {
            final protocol = link['protocol']?.toString() ?? '';
            
            if (protocol.toUpperCase().contains('WMS')) {
              final layerName = link['name']?.toString();
              
              if (layerName != null && layerName.isNotEmpty) {
                final title = _extractField(record, ['resourceTitle', 'title']) ?? layerName;
                final description = _extractField(record, ['resourceAbstract', 'abstract']);
                
                layers.add({
                  'name': layerName,
                  'title': title,
                  'description': description,
                  'url': link['url']?.toString() ?? '$_geoserverUrl/wms',
                  'metadata_id': record['uuid'] ?? record['_id'],
                });
                
                debugPrint('  ✓ Camada WMS: $title');
              }
            }
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao processar registro: $e');
        }
      }
      
      debugPrint('✅ ${layers.length} camadas WMS encontradas');
      return layers;
    } catch (e) {
      debugPrint('❌ Erro ao buscar camadas WMS: $e');
      return [];
    }
  }
  
  /// Busca camadas WMS via GetCapabilities do GeoServer
  /// 
  /// Método alternativo caso a busca por metadados falhe
  static Future<List<Map<String, dynamic>>> getWMSLayersFromCapabilities() async {
    try {
      debugPrint('🗺️ Buscando via WMS GetCapabilities...');
      
      const url = '$_geoserverUrl/wms?service=WMS&version=1.3.0&request=GetCapabilities';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );
      
      if (response.statusCode == 200) {
        final layers = <Map<String, dynamic>>[];
        final body = response.body;
        
        // Parse XML simples para extrair camadas
        final layerPattern = RegExp(
          r'<Layer[^>]*>.*?<Name>([^<]+)</Name>.*?<Title>([^<]*)</Title>',
          dotAll: true,
          multiLine: true,
        );
        
        final matches = layerPattern.allMatches(body);
        
        for (var match in matches) {
          final name = match.group(1);
          final title = match.group(2);
          
          if (name != null && name.contains(':')) {
            layers.add({
              'name': name,
              'title': title ?? name,
              'description': null,
              'url': '$_geoserverUrl/wms',
            });
          }
        }
        
        debugPrint('✅ ${layers.length} camadas encontradas via GetCapabilities');
        return layers;
      }
    } catch (e) {
      debugPrint('❌ Erro GetCapabilities: $e');
    }
    
    return [];
  }
  
  /// Busca dados de features via WFS
  /// 
  /// [layerName] - Nome da camada (ex: 'guarulhos:saude')
  /// [categoryId] - ID da categoria para associação
  static Future<List<Map<String, dynamic>>> fetchWFSData(
    String layerName,
    int categoryId,
  ) async {
    try {
      debugPrint('📦 Buscando dados WFS: $layerName');
      
      final url = '$_geoserverUrl/wfs?'
          'service=WFS&'
          'version=2.0.0&'
          'request=GetFeature&'
          'typeName=$layerName&'
          'outputFormat=application/json&'
          'srsName=EPSG:4326&'
          'count=1000';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List?;
        
        if (features != null && features.isNotEmpty) {
          debugPrint('  ✅ ${features.length} features encontradas');
          return _parseFeaturesToUnits(features, categoryId);
        } else {
          debugPrint('  ⚠️ Nenhuma feature encontrada');
        }
      } else {
        debugPrint('  ❌ Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('  ❌ Erro: $e');
    }
    
    return [];
  }
  
  /// Converte features GeoJSON para formato de unidades do app
  static List<Map<String, dynamic>> _parseFeaturesToUnits(
    List features,
    int categoryId,
  ) {
    final units = <Map<String, dynamic>>[];
    
    for (var feature in features) {
      try {
        final props = feature['properties'] as Map<String, dynamic>?;
        final geom = feature['geometry'];
        
        if (props == null || geom == null) continue;
        
        // Extrai coordenadas
        final coordinates = _extractCoordinates(geom);
        if (coordinates == null) continue;
        
        final lat = coordinates['lat']!;
        final lng = coordinates['lng']!;
        
        // Mapeia propriedades para campos do banco
        final unit = {
          'category_id': categoryId,
          'name': _extractProperty(props, ['nome', 'name', 'nm_equipamento', 'denominacao']) ?? 'Sem nome',
          'description': _extractProperty(props, ['descricao', 'description', 'obs']) ?? '',
          'address': _extractProperty(props, ['endereco', 'address', 'logradouro']) ?? 'Endereço não informado',
          'neighborhood': _extractProperty(props, ['bairro', 'neighborhood']) ?? 'Guarulhos',
          'zip_code': _extractProperty(props, ['cep', 'zip_code']) ?? '',
          'city': 'Guarulhos',
          'state': 'SP',
          'latitude': lat,
          'longitude': lng,
          'opening_hours': _extractProperty(props, ['horario', 'horario_funcionamento', 'funcionamento']) ?? '',
          'phone': _extractProperty(props, ['telefone', 'phone', 'fone', 'contato']) ?? '',
          'email': _extractProperty(props, ['email', 'e_mail']) ?? '',
          'website': _extractProperty(props, ['site', 'website', 'url', 'homepage']) ?? '',
        };
        
        units.add(unit);
      } catch (e) {
        debugPrint('⚠️ Erro ao processar feature: $e');
      }
    }
    
    return units;
  }
  
  /// Extrai coordenadas de diferentes tipos de geometria
  static Map<String, double>? _extractCoordinates(dynamic geometry) {
    try {
      final type = geometry['type'] as String?;
      final coords = geometry['coordinates'];
      
      if (coords == null) return null;
      
      switch (type) {
        case 'Point':
          final list = coords as List;
          return {
            'lng': _toDouble(list[0])!,
            'lat': _toDouble(list[1])!,
          };
          
        case 'MultiPoint':
          final list = coords as List;
          if (list.isNotEmpty) {
            final first = list[0] as List;
            return {
              'lng': _toDouble(first[0])!,
              'lat': _toDouble(first[1])!,
            };
          }
          break;
          
        case 'LineString':
          final list = coords as List;
          if (list.isNotEmpty) {
            // Usa o ponto central da linha
            final middle = list[list.length ~/ 2] as List;
            return {
              'lng': _toDouble(middle[0])!,
              'lat': _toDouble(middle[1])!,
            };
          }
          break;
          
        case 'Polygon':
          final list = coords as List;
          if (list.isNotEmpty && list[0] is List) {
            final ring = list[0] as List;
            if (ring.isNotEmpty) {
              // Usa o primeiro vértice do polígono
              final first = ring[0] as List;
              return {
                'lng': _toDouble(first[0])!,
                'lat': _toDouble(first[1])!,
              };
            }
          }
          break;
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao extrair coordenadas: $e');
    }
    
    return null;
  }
  
  /// Extrai propriedade com múltiplas tentativas de chaves
  static String? _extractProperty(Map<String, dynamic> props, List<String> possibleKeys) {
    for (var key in possibleKeys) {
      for (var propKey in props.keys) {
        if (propKey.toLowerCase() == key.toLowerCase()) {
          final value = props[propKey]?.toString().trim();
          if (value != null && value.isNotEmpty && value != 'null') {
            return value;
          }
        }
      }
    }
    return null;
  }
  
  /// Extrai campo de registro de metadado (suporta arrays e strings)
  static String? _extractField(Map<String, dynamic> record, List<String> possibleKeys) {
    for (var key in possibleKeys) {
      final value = record[key];
      
      if (value == null) continue;
      
      if (value is List && value.isNotEmpty) {
        return value.first?.toString().trim();
      }
      
      if (value is String && value.isNotEmpty) {
        return value.trim();
      }
    }
    
    return null;
  }
  
  /// Converte valor para double com segurança
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
  
  /// Busca todas as unidades de serviço de todas as categorias
  /// 
  /// Usa mapeamento de camadas conhecidas do GeoServer de Guarulhos
  static Future<List<Map<String, dynamic>>> fetchAllServiceUnits() async {
    debugPrint('\n🚀 Iniciando busca de dados do GeoNetwork...\n');
    
    final allUnits = <Map<String, dynamic>>[];
    
    // Mapeamento de camadas do GeoServer de Guarulhos
    // Ajuste conforme as camadas reais disponíveis
    final layerMapping = {
      // Saúde (categoria 1)
      'guarulhos:saude_equipamentos': 1,
      'guarulhos:unidades_saude': 1,
      'guarulhos:hospitais': 1,
      'guarulhos:ubs': 1,
      
      // Educação (categoria 2)
      'guarulhos:escolas_municipais': 2,
      'guarulhos:escolas_estaduais': 2,
      'guarulhos:educacao': 2,
      
      // Comunidade (categoria 3)
      'guarulhos:equipamentos_sociais': 3,
      'guarulhos:centros_comunitarios': 3,
      
      // Segurança (categoria 4)
      'guarulhos:seguranca_publica': 4,
      'guarulhos:delegacias': 4,
      
      // Transporte (categoria 5)
      'guarulhos:transporte_publico': 5,
      'guarulhos:pontos_onibus': 5,
      
      // Cultura e Lazer (categoria 6)
      'guarulhos:equipamentos_culturais': 6,
      'guarulhos:parques': 6,
      'guarulhos:espacos_lazer': 6,
    };
    
    for (var entry in layerMapping.entries) {
      final units = await fetchWFSData(entry.key, entry.value);
      
      if (units.isNotEmpty) {
        allUnits.addAll(units);
        debugPrint('  ✓ ${units.length} unidades da camada ${entry.key}');
      }
      
      // Delay para não sobrecarregar o servidor
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    debugPrint('\n✅ Total: ${allUnits.length} unidades carregadas\n');
    return allUnits;
  }
  
  /// Lista todas as camadas WFS disponíveis no GeoServer
  static Future<List<String>> getAvailableWFSLayers() async {
    try {
      debugPrint('📋 Listando camadas WFS disponíveis...');
      
      const url = '$_geoserverUrl/wfs?'
          'service=WFS&'
          'version=2.0.0&'
          'request=GetCapabilities';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );
      
      if (response.statusCode == 200) {
        final layers = <String>[];
        final body = response.body;
        
        // Parse XML simples para extrair nomes de camadas
        final pattern = RegExp(r'<Name>([^<]+)</Name>');
        final matches = pattern.allMatches(body);
        
        for (var match in matches) {
          final layerName = match.group(1);
          if (layerName != null && layerName.contains(':')) {
            layers.add(layerName);
          }
        }
        
        debugPrint('✅ ${layers.length} camadas WFS encontradas');
        return layers;
      }
    } catch (e) {
      debugPrint('❌ Erro: $e');
    }
    
    return [];
  }
}