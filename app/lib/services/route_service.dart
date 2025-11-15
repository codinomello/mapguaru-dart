import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

/// Serviço para cálculo de rotas usando OpenRouteService
/// 
/// API gratuita com limite de 2000 requisições/dia
class RouteService {
  // IMPORTANTE: Substitua por sua própria chave da OpenRouteService
  // Obtenha em: https://openrouteservice.org/dev/#/signup
  static const String _apiKey = '5b3ce3597851110001cf62489d7a4f9ed9c44d1d95d4d2c9c4b3e5f6';
  static const String _baseUrl = 'https://api.openrouteservice.org/v2/directions';
  
  /// Calcula rota entre dois pontos
  /// 
  /// [start] - Ponto inicial (LatLng)
  /// [end] - Ponto final (LatLng)
  /// [profile] - Modo de transporte:
  ///   - 'foot-walking': A pé
  ///   - 'driving-car': De carro
  ///   - 'cycling-regular': Bicicleta
  static Future<Map<String, dynamic>?> calculateRoute({
    required LatLng start,
    required LatLng end,
    String profile = 'foot-walking',
  }) async {
    try {
      debugPrint('📍 Calculando rota de ${start} até ${end}');
      
      final url = Uri.parse('$_baseUrl/$profile');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': _apiKey,
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json, application/geo+json',
        },
        body: json.encode({
          'coordinates': [
            [start.longitude, start.latitude],
            [end.longitude, end.latitude],
          ],
          'instructions': true,
          'language': 'pt',
          'units': 'km',
        }),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        debugPrint('✅ Rota calculada com sucesso');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('❌ Erro na API: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Erro ao calcular rota: $e');
      return null;
    }
  }
  
  /// Extrai pontos da rota para desenhar no mapa
  static List<LatLng> extractRoutePoints(Map<String, dynamic> routeData) {
    try {
      final List<dynamic> coordinates = 
          routeData['features'][0]['geometry']['coordinates'];
      
      return coordinates.map((coord) {
        return LatLng(coord[1] as double, coord[0] as double);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao extrair pontos da rota: $e');
      return [];
    }
  }
  
  /// Extrai informações resumidas da rota (distância e tempo)
  static Map<String, dynamic> extractRouteInfo(Map<String, dynamic> routeData) {
    try {
      final summary = routeData['features'][0]['properties']['summary'];
      
      return {
        'distance': (summary['distance'] as num) / 1000, // em km
        'duration': (summary['duration'] as num) / 60, // em minutos
      };
    } catch (e) {
      debugPrint('❌ Erro ao extrair info da rota: $e');
      return {
        'distance': 0.0,
        'duration': 0.0,
      };
    }
  }

  /// Extrai instruções passo a passo da rota
  static List<RouteStep> extractRouteSteps(Map<String, dynamic> routeData) {
    try {
      final List<dynamic> segments = 
          routeData['features'][0]['properties']['segments'];
      
      final List<RouteStep> steps = [];
      
      for (var segment in segments) {
        final List<dynamic> stepsData = segment['steps'];
        
        for (var stepData in stepsData) {
          steps.add(RouteStep(
            instruction: stepData['instruction'] as String,
            distance: (stepData['distance'] as num).toDouble(),
            duration: (stepData['duration'] as num).toDouble(),
            type: stepData['type'] as int,
          ));
        }
      }
      
      return steps;
    } catch (e) {
      debugPrint('❌ Erro ao extrair passos da rota: $e');
      return [];
    }
  }

  /// Formata distância para exibição
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Formata duração para exibição
  static String formatDuration(double durationMin) {
    if (durationMin < 60) {
      return '${durationMin.toStringAsFixed(0)} min';
    }
    
    final hours = durationMin ~/ 60;
    final minutes = (durationMin % 60).toStringAsFixed(0);
    
    return '${hours}h ${minutes}min';
  }
}

/// Modelo para um passo da rota
class RouteStep {
  final String instruction;
  final double distance;
  final double duration;
  final int type;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.type,
  });

  String get formattedDistance => RouteService.formatDistance(distance / 1000);
  String get formattedDuration => RouteService.formatDuration(duration / 60);
}