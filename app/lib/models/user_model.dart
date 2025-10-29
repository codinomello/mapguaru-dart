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