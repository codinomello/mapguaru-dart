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