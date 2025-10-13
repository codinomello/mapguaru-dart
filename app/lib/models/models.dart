// ==================== USER MODEL ====================

/// Modelo de dados para representar um usuário do sistema
/// 
/// Contém informações de autenticação e perfil do usuário
class User {
  final int? userId;
  final String name;
  final String email;
  final String? passwordHash;
  final String? firebaseUid;
  final DateTime createdAt;

  User({
    this.userId,
    required this.name,
    required this.email,
    this.passwordHash,
    this.firebaseUid,
    required this.createdAt,
  });

  /// Cria um User a partir de um Map (dados do banco)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String?,
      firebaseUid: map['firebase_uid'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Converte o User para Map (para salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'firebase_uid': firebaseUid,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Cria uma cópia do User com campos atualizados
  User copyWith({
    int? userId,
    String? name,
    String? email,
    String? passwordHash,
    String? firebaseUid,
    DateTime? createdAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ==================== SERVICE CATEGORY MODEL ====================

/// Modelo de dados para categorias de serviços
/// 
/// Representa as 6 categorias principais: Saúde, Educação, 
/// Comunidade, Segurança, Transporte e Cultura & Lazer
class ServiceCategory {
  final int? categoryId;
  final String name;
  final String? description;
  final String icon;

  ServiceCategory({
    this.categoryId,
    required this.name,
    this.description,
    required this.icon,
  });

  /// Cria um ServiceCategory a partir de um Map
  factory ServiceCategory.fromMap(Map<String, dynamic> map) {
    return ServiceCategory(
      categoryId: map['category_id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String,
    );
  }

  /// Converte o ServiceCategory para Map
  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'name': name,
      'description': description,
      'icon': icon,
    };
  }
}

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
      category: map['category'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      address: map['address'] as String,
      neighborhood: map['neighborhood'] as String?,
      zipCode: map['zip_code'] as String?,
      city: map['city'] as String,
      state: map['state'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      openingHours: map['opening_hours'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
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

// ==================== REQUIRED DOCUMENT MODEL ====================

/// Modelo de dados para documentos necessários
/// 
/// Representa a lista de documentos que o usuário precisa 
/// levar para acessar um determinado serviço
class RequiredDocument {
  final int? documentId;
  final int unitId;
  final String name;
  final String? description;

  RequiredDocument({
    this.documentId,
    required this.unitId,
    required this.name,
    this.description,
  });

  /// Cria um RequiredDocument a partir de um Map
  factory RequiredDocument.fromMap(Map<String, dynamic> map) {
    return RequiredDocument(
      documentId: map['document_id'] as int?,
      unitId: map['unit_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
    );
  }

  /// Converte o RequiredDocument para Map
  Map<String, dynamic> toMap() {
    return {
      'document_id': documentId,
      'unit_id': unitId,
      'name': name,
      'description': description,
    };
  }
}

// ==================== FAVORITE MODEL ====================

/// Modelo de dados para favoritos do usuário
/// 
/// Relaciona usuários com suas unidades de serviço favoritas
class Favorite {
  final int? favoriteId;
  final int userId;
  final int unitId;
  final DateTime createdAt;

  Favorite({
    this.favoriteId,
    required this.userId,
    required this.unitId,
    required this.createdAt,
  });

  /// Cria um Favorite a partir de um Map
  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      favoriteId: map['favorite_id'] as int?,
      userId: map['user_id'] as int,
      unitId: map['unit_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Converte o Favorite para Map
  Map<String, dynamic> toMap() {
    return {
      'favorite_id': favoriteId,
      'user_id': userId,
      'unit_id': unitId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ==================== NEWS MODEL ====================

/// Modelo de dados para notícias e eventos
/// 
/// Representa informações sobre eventos, obras, 
/// mudanças temporárias de serviços, etc.
class News {
  final int? newsId;
  final String title;
  final String? description;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? serviceType;
  final DateTime createdAt;

  News({
    this.newsId,
    required this.title,
    this.description,
    this.location,
    this.startDate,
    this.endDate,
    this.serviceType,
    required this.createdAt,
  });

  /// Cria um News a partir de um Map
  factory News.fromMap(Map<String, dynamic> map) {
    return News(
      newsId: map['news_id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      location: map['location'] as String?,
      startDate: map['start_date'] != null 
          ? DateTime.parse(map['start_date'] as String) 
          : null,
      endDate: map['end_date'] != null 
          ? DateTime.parse(map['end_date'] as String) 
          : null,
      serviceType: map['service_type'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Converte o News para Map
  Map<String, dynamic> toMap() {
    return {
      'news_id': newsId,
      'title': title,
      'description': description,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'service_type': serviceType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Verifica se o evento está ativo
  bool get isActive {
    final now = DateTime.now();
    if (startDate != null && endDate != null) {
      return now.isAfter(startDate!) && now.isBefore(endDate!);
    }
    return true;
  }
}