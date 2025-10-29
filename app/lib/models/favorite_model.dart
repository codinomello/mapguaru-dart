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