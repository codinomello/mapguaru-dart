// ==================== CUSTOM MARKER MODEL ====================

/// Modelo de dados para marcadores personalizados do usuário
/// 
/// Permite que usuários adicionem seus próprios locais no mapa
class CustomMarker {
  final int? markerId;
  final int userId;
  final String name;
  final String? description;
  final String? address;
  final double latitude;
  final double longitude;
  final String? category; // 'pessoal', 'trabalho', 'lazer', 'outros'
  final String? icon; // Nome do ícone
  final String? color; // Cor em hex
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CustomMarker({
    this.markerId,
    required this.userId,
    required this.name,
    this.description,
    this.address,
    required this.latitude,
    required this.longitude,
    this.category,
    this.icon,
    this.color,
    this.isFavorite = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Cria um CustomMarker a partir de um Map (dados do banco)
  factory CustomMarker.fromMap(Map<String, dynamic> map) {
    return CustomMarker(
      markerId: map['marker_id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      address: map['address'] as String?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      category: map['category'] as String?,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      isFavorite: (map['is_favorite'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Converte o CustomMarker para Map (para salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      'marker_id': markerId,
      'user_id': userId,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'icon': icon,
      'color': color,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Cria uma cópia com campos atualizados
  CustomMarker copyWith({
    int? markerId,
    int? userId,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? category,
    String? icon,
    String? color,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomMarker(
      markerId: markerId ?? this.markerId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Categorias disponíveis
  static const List<Map<String, dynamic>> categories = [
    {'id': 'pessoal', 'name': 'Pessoal', 'icon': 'home', 'color': '#2563EB'},
    {'id': 'trabalho', 'name': 'Trabalho', 'icon': 'work', 'color': '#059669'},
    {'id': 'lazer', 'name': 'Lazer', 'icon': 'sports_soccer', 'color': '#F59E0B'},
    {'id': 'compras', 'name': 'Compras', 'icon': 'shopping_cart', 'color': '#7C3AED'},
    {'id': 'saude', 'name': 'Saúde', 'icon': 'local_hospital', 'color': '#DC2626'},
    {'id': 'outros', 'name': 'Outros', 'icon': 'place', 'color': '#6B7280'},
  ];

  /// Retorna informações da categoria
  static Map<String, dynamic>? getCategoryInfo(String? categoryId) {
    if (categoryId == null) return null;
    return categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => categories.last,
    );
  }
}