import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// Serviço para gerenciar contatos e funcionalidades de emergência
class EmergencyService {
  
  /// Lista de contatos de emergência de Guarulhos
  static List<EmergencyContact> get emergencyContacts => [
    EmergencyContact(
      name: 'SAMU - Urgência Médica',
      number: '192',
      description: 'Atendimento médico de urgência e emergência',
      icon: Icons.local_hospital,
      color: const Color(0xFFDC2626),
      category: EmergencyCategory.health,
    ),
    EmergencyContact(
      name: 'Polícia Militar',
      number: '190',
      description: 'Ocorrências policiais e emergências',
      icon: Icons.local_police,
      color: const Color(0xFF1E40AF),
      category: EmergencyCategory.security,
    ),
    EmergencyContact(
      name: 'Bombeiros',
      number: '193',
      description: 'Incêndios, resgates e emergências',
      icon: Icons.fire_truck,
      color: const Color(0xFFEA580C),
      category: EmergencyCategory.fire,
    ),
    EmergencyContact(
      name: 'Defesa Civil',
      number: '199',
      description: 'Enchentes, deslizamentos e desastres naturais',
      icon: Icons.shield,
      color: const Color(0xFF059669),
      category: EmergencyCategory.civil,
    ),
    EmergencyContact(
      name: 'Guarda Civil Municipal',
      number: '153',
      description: 'Segurança municipal e patrimônio público',
      icon: Icons.security,
      color: const Color(0xFF7C3AED),
      category: EmergencyCategory.security,
    ),
    EmergencyContact(
      name: 'SAC Guarulhos',
      number: '156',
      description: 'Serviço de Atendimento ao Cidadão',
      icon: Icons.support_agent,
      color: const Color(0xFF2563EB),
      category: EmergencyCategory.general,
    ),
    EmergencyContact(
      name: 'Disque Denúncia',
      number: '181',
      description: 'Denúncias anônimas de crimes',
      icon: Icons.report,
      color: const Color(0xFF9333EA),
      category: EmergencyCategory.security,
    ),
    EmergencyContact(
      name: 'Procon Guarulhos',
      number: '(11) 2087-8000',
      description: 'Defesa do consumidor',
      icon: Icons.gavel,
      color: const Color(0xFFF59E0B),
      category: EmergencyCategory.general,
    ),
    EmergencyContact(
      name: 'Semae - Água e Esgoto',
      number: '0800 011 9911',
      description: 'Emergências de água e esgoto',
      icon: Icons.water_drop,
      color: const Color(0xFF0EA5E9),
      category: EmergencyCategory.utilities,
    ),
    EmergencyContact(
      name: 'Enel - Energia Elétrica',
      number: '0800 701 0102',
      description: 'Falta de luz e emergências elétricas',
      icon: Icons.electric_bolt,
      color: const Color(0xFFEAB308),
      category: EmergencyCategory.utilities,
    ),
  ];

  /// Faz ligação telefônica
  static Future<bool> makeCall(String number) async {
    try {
      // Remove caracteres não numéricos (exceto +)
      final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri(scheme: 'tel', path: cleanNumber);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao fazer ligação: $e');
      return false;
    }
  }

  /// Abre WhatsApp (para contatos que suportam)
  static Future<bool> openWhatsApp(String number, [String? message]) async {
    try {
      final cleanNumber = number.replaceAll(RegExp(r'[^\d]'), '');
      final text = message != null ? Uri.encodeComponent(message) : '';
      final uri = Uri.parse('https://wa.me/55$cleanNumber?text=$text');
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao abrir WhatsApp: $e');
      return false;
    }
  }

  /// Filtra contatos por categoria
  static List<EmergencyContact> getContactsByCategory(EmergencyCategory category) {
    return emergencyContacts.where((c) => c.category == category).toList();
  }

  /// Busca contatos
  static List<EmergencyContact> searchContacts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return emergencyContacts.where((contact) {
      return contact.name.toLowerCase().contains(lowercaseQuery) ||
             contact.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}

/// Categorias de emergência
enum EmergencyCategory {
  health,    // Saúde
  security,  // Segurança
  fire,      // Bombeiros
  civil,     // Defesa Civil
  utilities, // Serviços essenciais
  general,   // Geral
}

/// Modelo de contato de emergência
class EmergencyContact {
  final String name;
  final String number;
  final String description;
  final IconData icon;
  final Color color;
  final EmergencyCategory category;
  final bool isPriority;

  EmergencyContact({
    required this.name,
    required this.number,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    this.isPriority = false,
  });

  /// Retorna nome da categoria em português
  String get categoryName {
    switch (category) {
      case EmergencyCategory.health:
        return 'Saúde';
      case EmergencyCategory.security:
        return 'Segurança';
      case EmergencyCategory.fire:
        return 'Bombeiros';
      case EmergencyCategory.civil:
        return 'Defesa Civil';
      case EmergencyCategory.utilities:
        return 'Serviços Essenciais';
      case EmergencyCategory.general:
        return 'Geral';
    }
  }
}