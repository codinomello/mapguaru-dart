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
