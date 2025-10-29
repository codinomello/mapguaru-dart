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