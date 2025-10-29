import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ========================================
// SERVIÇO PARA BUSCAR DADOS DO GEONETWORK
// Usa a API REST moderna do GeoNetwork 4.x
// ========================================

class GeoNetworkService {
  static const String _baseUrl = 'https://geonetwork.guarulhos.sp.gov.br:8443';
  static const String _geoserverUrl = '$_baseUrl/geoserver';
  static const String _geonetworkUrl = '$_baseUrl/geonetwork';
  
  // --- NOVO MÉTODO: Busca e extrai informações WMS de um metadado específico ---
  static Future<Map<String, dynamic>?> getWMSLayerById(String metadataId) async {
    try {
      debugPrint('🗺️ Buscando metadado específico WMS: $metadataId...');
      
      // Altere o endpoint para uma rota de API mais robusta para GeoNetwork 4.x.
      // O /search/records/$metadataId deve funcionar melhor que o /formatters/json-full
      final url = '$_geonetworkUrl/srv/api/search/records/$metadataId'; // <-- URL CORRIGIDA
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final record = json.decode(response.body) as Map<String, dynamic>;
        
        // Tentativa de extrair link WMS
        final links = record['link'] as List?;
        if (links != null) {
          for (var link in links) {
            final protocol = link['protocol'] as String?;
            if (protocol != null && protocol.contains('WMS')) {
              final layerName = link['name'] as String?;
              final title = record['resourceTitle']?.first ?? layerName;
              final description = record['resourceAbstract']?.first;
              
              if (layerName != null) {
                debugPrint('✅ Camada WMS encontrada por ID: $layerName');
                return {
                  'name': layerName,
                  'title': title,
                  'description': description,
                  'url': link['url'],
                };
              }
            }
          }
        }
      } else {
        debugPrint('⚠️ Status ao buscar por ID: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar camada por ID: $e');
    }
    
    return null;
  }

  /// Busca metadados via API REST do GeoNetwork
  static Future<List<Map<String, dynamic>>> searchMetadata({
    String? query,
    int from = 0,
    int size = 100,
  }) async {
    try {
      debugPrint('🔍 Buscando metadados no GeoNetwork...');
      
      // API REST do GeoNetwork 4.x
      final url = '$_geonetworkUrl/srv/api/search/records/_search';
      
      final requestBody = {
        'from': from,
        'size': size,
        'query': {
          'query_string': {
            'query': query ?? '*'
          }
        }
      };
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hits = data['hits']?['hits'] as List?;
        
        if (hits != null) {
          debugPrint('✅ ${hits.length} metadados encontrados');
          return hits.map((hit) => hit['_source'] as Map<String, dynamic>).toList();
        }
      } else {
        debugPrint('⚠️ Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar metadados: $e');
    }
    
    return [];
  }
  
  /// Extrai layers WMS dos metadados
  static Future<List<Map<String, dynamic>>> getWMSLayers() async {
    try {
      debugPrint('🗺️ Buscando camadas WMS...');
      
      final metadata = await searchMetadata(query: 'protocol:OGC\\:WMS');
      final layers = <Map<String, dynamic>>[];
      
      for (var record in metadata) {
        try {
          final links = record['link'] as List?;
          if (links == null) continue;
          
          for (var link in links) {
            final protocol = link['protocol'];
            if (protocol != null && protocol.toString().contains('WMS')) {
              final layerName = link['name'];
              final title = record['resourceTitle']?.first ?? layerName;
              final description = record['resourceAbstract']?.first;
              
              if (layerName != null) {
                layers.add({
                  'name': layerName,
                  'title': title,
                  'description': description,
                  'url': link['url'],
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
  
  /// Busca camadas WFS via GetCapabilities (método alternativo)
  static Future<List<Map<String, dynamic>>> getWMSLayersFromCapabilities() async {
    try {
      debugPrint('🗺️ Buscando via WMS GetCapabilities...');
      
      const url = '$_geoserverUrl/wms?service=WMS&version=1.3.0&request=GetCapabilities';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final layers = <Map<String, dynamic>>[];
        
        // Parse XML simples para extrair nomes de camadas
        final body = response.body;
        final pattern = RegExp(r'<Layer[^>]*>.*?<Name>([^<]+)</Name>.*?<Title>([^<]*)</Title>', 
          dotAll: true, multiLine: true);
        final matches = pattern.allMatches(body);
        
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
        
        debugPrint('✅ ${layers.length} camadas WMS encontradas via GetCapabilities');
        return layers;
      }
    } catch (e) {
      debugPrint('❌ Erro GetCapabilities: $e');
    }
    
    return [];
  }
  
  /// Busca dados via WFS do GeoServer
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
          'srsName=EPSG:4326';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 20),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List?;
        
        if (features != null && features.isNotEmpty) {
          debugPrint('  ✅ ${features.length} features encontradas');
          return _parseFeatures(features, categoryId);
        }
      } else {
        debugPrint('  ❌ Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('  ❌ Erro: $e');
    }
    
    return [];
  }
  
  /// Parse features GeoJSON para formato do app
  static List<Map<String, dynamic>> _parseFeatures(
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
        double? lat, lng;
        
        if (geom['type'] == 'Point') {
          final coords = geom['coordinates'] as List;
          lng = _toDouble(coords[0]);
          lat = _toDouble(coords[1]);
        } else if (geom['type'] == 'MultiPoint') {
          final coords = geom['coordinates'] as List;
          if (coords.isNotEmpty) {
            final first = coords[0] as List;
            lng = _toDouble(first[0]);
            lat = _toDouble(first[1]);
          }
        }
        
        if (lat == null || lng == null) continue;
        
        // Mapeia atributos
        final unit = {
          'category_id': categoryId,
          'name': _extract(props, ['nome', 'name', 'nm_equipamento', 'denominacao']) ?? 'Sem nome',
          'description': _extract(props, ['descricao', 'description', 'obs']) ?? '',
          'address': _extract(props, ['endereco', 'address', 'logradouro']) ?? 'Endereço não informado',
          'neighborhood': _extract(props, ['bairro', 'neighborhood']) ?? 'Guarulhos',
          'zip_code': '',
          'city': 'Guarulhos',
          'state': 'SP',
          'latitude': lat,
          'longitude': lng,
          'opening_hours': _extract(props, ['horario', 'funcionamento']) ?? '',
          'phone': _extract(props, ['telefone', 'phone', 'fone']) ?? '',
          'email': _extract(props, ['email']) ?? '',
          'website': _extract(props, ['site', 'website', 'url']) ?? '',
        };
        
        units.add(unit);
      } catch (e) {
        debugPrint('⚠️ Erro ao processar feature: $e');
      }
    }
    
    return units;
  }
  
  /// Extrai propriedade com fallbacks
  static String? _extract(Map<String, dynamic> props, List<String> keys) {
    for (var key in keys) {
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
  
  /// Converte para double com segurança
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
  
  /// Busca todos os dados de todas as camadas configuradas
  static Future<List<Map<String, dynamic>>> fetchAllServiceUnits() async {
    debugPrint('\n🚀 Iniciando busca de dados do GeoNetwork...\n');
    
    final allUnits = <Map<String, dynamic>>[];
    
    // Mapeamento de camadas (ajuste conforme camadas reais do servidor)
    final layerMapping = {
      // Saúde
      'guarulhos:saude': 1,
      'guarulhos:hospitais': 1,
      'guarulhos:ubs': 1,
      
      // Educação
      'guarulhos:escolas': 2,
      'guarulhos:educacao': 2,
      
      // Comunidade
      'guarulhos:equipamentos_sociais': 3,
      
      // Segurança
      'guarulhos:seguranca': 4,
      
      // Transporte
      'guarulhos:transporte': 5,
      
      // Cultura
      'guarulhos:cultura': 6,
      'guarulhos:lazer': 6,
    };
    
    for (var entry in layerMapping.entries) {
      final units = await fetchWFSData(entry.key, entry.value);
      allUnits.addAll(units);
      
      // Delay para não sobrecarregar o servidor
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    debugPrint('\n✅ Total: ${allUnits.length} unidades carregadas\n');
    return allUnits;
  }
  
  /// Lista camadas WFS disponíveis (GetCapabilities)
  static Future<List<String>> getAvailableWFSLayers() async {
    try {
      debugPrint('📋 Buscando camadas WFS disponíveis...');
      
      const url = '$_geoserverUrl/wfs?'
          'service=WFS&'
          'version=2.0.0&'
          'request=GetCapabilities';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final layers = <String>[];
        
        // Parse XML simples
        final body = response.body;
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