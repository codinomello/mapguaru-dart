// ==================== SERVICE UNIT MODEL ====================

/// Modelo de dados para unidades prestadoras de serviço
/// 
/// Representa locais físicos como hospitais, escolas, 
/// delegacias, etc. com suas informações de localização e contato
class ServiceUnit {
  final int? unitId;
  final int category;
  final String name;
  final String? description;
  final String address;
  final String? neighborhood;
  final String? zipCode;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String? openingHours;
  final String? phone;
  final String? email;
  final String? website;
  final DateTime createdAt;

  ServiceUnit({
    this.unitId,
    required this.category,
    required this.name,
    this.description,
    required this.address,
    this.neighborhood,
    this.zipCode,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    this.openingHours,
    this.phone,
    this.email,
    this.website,
    required this.createdAt,
  });

  /// Cria um ServiceUnit a partir de um Map
  factory ServiceUnit.fromMap(Map<String, dynamic> map) {
    return ServiceUnit(
      unitId: map['unit_id'] as int?,
      category: map['category_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      address: map['address'] as String,
      neighborhood: map['neighborhood'] as String?,
      zipCode: map['zip_code'] as String?,
      city: map['city'] as String,
      state: map['state'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      openingHours: map['opening_hours'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      createdAt: DateTime.now(),
    );
  }

  /// Converte o ServiceUnit para Map
  Map<String, dynamic> toMap() {
    return {
      'unit_id': unitId,
      'category': category,
      'name': name,
      'description': description,
      'address': address,
      'neighborhood': neighborhood,
      'zip_code': zipCode,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'opening_hours': openingHours,
      'phone': phone,
      'email': email,
      'website': website,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Retorna endereço completo formatado
  String get fullAddress {
    final parts = [address];
    if (neighborhood != null) parts.add(neighborhood!);
    if (zipCode != null) parts.add('CEP: $zipCode');
    parts.add('$city - $state');
    return parts.join(', ');
  }
}
