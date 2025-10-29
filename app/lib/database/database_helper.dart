import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DatabaseHelper {
  // Padrão Singleton para garantir uma única instância do banco
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mapguaru.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Chamado na primeira vez que o banco é criado
  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // Tabela de Usuários
      await txn.execute('''
        CREATE TABLE users (
          user_id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');

      // Tabela de Categorias
      await txn.execute('''
        CREATE TABLE categories (
          category_id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          icon TEXT NOT NULL
        )
      ''');

      // Tabela de Unidades de Serviço
      await txn.execute('''
        CREATE TABLE service_units (
          unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          address TEXT NOT NULL,
          neighborhood TEXT,
          zip_code TEXT,
          city TEXT,
          state TEXT,
          phone TEXT,
          email TEXT,
          website TEXT,
          opening_hours TEXT,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          FOREIGN KEY (category_id) REFERENCES categories (category_id)
        )
      ''');

      // Tabela de Favoritos (Tabela de Junção)
      await txn.execute('''
        CREATE TABLE favorites (
          user_id INTEGER NOT NULL,
          unit_id INTEGER NOT NULL,
          PRIMARY KEY (user_id, unit_id),
          FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
          FOREIGN KEY (unit_id) REFERENCES service_units (unit_id) ON DELETE CASCADE
        )
      ''');

      // Popular a tabela de categorias com dados iniciais
      await _populateCategories(txn);
    });
  }

  /// Popula a tabela de categorias
  Future<void> _populateCategories(Transaction txn) async {
    final categories = [
      {'category_id': 1, 'name': 'Saúde', 'icon': 'health'},
      {'category_id': 2, 'name': 'Educação', 'icon': 'education'},
      {'category_id': 3, 'name': 'Comunidade', 'icon': 'community'},
      {'category_id': 4, 'name': 'Segurança', 'icon': 'security'},
      {'category_id': 5, 'name': 'Transporte', 'icon': 'transport'},
      {'category_id': 6, 'name': 'Cultura & Lazer', 'icon': 'culture'},
    ];
    for (var category in categories) {
      await txn.insert('categories', category);
    }
  }  

  // ============== MÉTODOS PARA USUÁRIOS ==============

  /// Registra um novo usuário
  Future<int?> registerUser(String name, String email, String password) async {
    final db = await database;
    // Verifica se o email já existe
    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (existingUser.isNotEmpty) {
      return null; // Retorna nulo se o email já estiver em uso
    }
    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password, // ATENÇÃO: Em um app real, use criptografia (ex: bcrypt)
    });
  }

  /// Autentica um usuário
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  /// Atualiza dados do usuário
  Future<int> updateUser(int userId, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'users',
      data,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ============== MÉTODOS PARA CATEGORIAS ==============

  /// Busca todas as categorias
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'category_id');
  }

  // ============== MÉTODOS PARA UNIDADES DE SERVIÇO ==============

  /// Insere uma nova unidade de serviço
  Future<int> insertServiceUnit(Map<String, dynamic> unit) async {
    final db = await database;
    return await db.insert(
      'service_units', 
      unit,
      conflictAlgorithm: ConflictAlgorithm.replace, // 🆕 Substitui se já existir
    );
  }
  
  /// Busca todas as unidades de serviço
  Future<List<Map<String, dynamic>>> getAllServiceUnits() async {
    final db = await database;
    return await db.query('service_units');
  }

  /// Busca unidades de serviço por categoria
  Future<List<Map<String, dynamic>>> getServiceUnitsByCategory(int categoryId) async {
    final db = await database;
    return await db.query(
      'service_units',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  /// 🆕 Limpa todas as unidades de serviço (para re-popular com dados da API)
  Future<void> clearAllServiceUnits() async {
    final db = await database;
    await db.delete('service_units');
  }

  /// 🆕 Conta quantas unidades existem no banco
  Future<int> countServiceUnits() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM service_units');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 🆕 Verifica se uma unidade já existe pelo nome e coordenadas
  Future<bool> serviceUnitExists(String name, double lat, double lng) async {
    final db = await database;
    final result = await db.query(
      'service_units',
      where: 'name = ? AND latitude = ? AND longitude = ?',
      whereArgs: [name, lat, lng],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ============== MÉTODOS PARA FAVORITOS ==============

  /// Adiciona um favorito
  Future<void> addFavorite(int userId, int unitId) async {
    final db = await database;
    await db.insert(
      'favorites',
      {'user_id': userId, 'unit_id': unitId},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Ignora se já existir
    );
  }

  /// Remove um favorito
  Future<void> removeFavorite(int userId, int unitId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'user_id = ? AND unit_id = ?',
      whereArgs: [userId, unitId],
    );
  }

  /// Busca todos os favoritos de um usuário
  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    final db = await database;
    // Junta as tabelas favorites e service_units para obter detalhes completos
    return await db.rawQuery('''
      SELECT u.* FROM service_units u
      INNER JOIN favorites f ON u.unit_id = f.unit_id
      WHERE f.user_id = ?
    ''', [userId]);
  }
}