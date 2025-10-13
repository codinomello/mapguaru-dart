import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/database_helper.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/category_detail_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/service_guide_screen.dart';

/// Ponto de entrada do aplicativo MapGuaru
/// 
/// Inicializa o banco de dados, configurações e providers
/// antes de executar o app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientação (apenas retrato)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inicializar banco de dados e popular com dados de exemplo
  final dbHelper = DatabaseHelper();
  await _initializeSampleData(dbHelper);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const MapGuaruApp(),
    ),
  );
}

/// Inicializa dados de exemplo no banco de dados
/// 
/// Verifica se é a primeira execução e popula o banco
/// com unidades de serviço de exemplo
Future<void> _initializeSampleData(DatabaseHelper dbHelper) async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool(AppConstants.keyFirstTime) ?? true;
  
  if (isFirstTime) {
    // Inserir unidades de serviço de exemplo
    for (var unit in AppConstants.sampleServiceUnits) {
      await dbHelper.insertServiceUnit(unit);
    }
    
    await prefs.setBool(AppConstants.keyFirstTime, false);
  }
}

/// Widget raiz do aplicativo
class MapGuaruApp extends StatelessWidget {
  const MapGuaruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // Rota inicial
      initialRoute: AppConstants.routeSplash,
      
      // Definição de rotas
      routes: {
        AppConstants.routeSplash: (context) => const SplashScreen(),
        AppConstants.routeMenu: (context) => const MenuScreen(),
        AppConstants.routeLogin: (context) => const LoginScreen(),
        AppConstants.routeRegister: (context) => const RegisterScreen(),
        AppConstants.routeMainMenu: (context) => const MainMenuScreen(),
        AppConstants.routeMap: (context) => const MapScreen(),
        AppConstants.routeProfile: (context) => const ProfileScreen(),
        AppConstants.routeServiceGuide: (context) => const ServiceGuideScreen(),
      },
      
      // Rota com argumentos
      onGenerateRoute: (settings) {
        if (settings.name == AppConstants.routeCategory) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(
              categoryId: args['categoryId'],
              categoryName: args['categoryName'],
            ),
          );
        }
        return null;
      },
    );
  }
}

// ==================== PROVIDERS ====================

/// Provider para gerenciar estado do usuário
/// 
/// Mantém informações do usuário logado e fornece
/// métodos para login/logout
class UserProvider with ChangeNotifier {
  int? _userId;
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;

  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;

  /// Carrega dados do usuário do SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt(AppConstants.keyUserId);
    _userName = prefs.getString(AppConstants.keyUserName);
    _userEmail = prefs.getString(AppConstants.keyUserEmail);
    _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    notifyListeners();
  }

  /// Faz login do usuário
  Future<void> login(int userId, String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    
    _userId = userId;
    _userName = name;
    _userEmail = email;
    _isLoggedIn = true;
    
    await prefs.setInt(AppConstants.keyUserId, userId);
    await prefs.setString(AppConstants.keyUserName, name);
    await prefs.setString(AppConstants.keyUserEmail, email);
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    
    notifyListeners();
  }

  /// Faz logout do usuário
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    _userId = null;
    _userName = null;
    _userEmail = null;
    _isLoggedIn = false;
    
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keyUserEmail);
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    
    notifyListeners();
  }

  /// Atualiza nome do usuário
  Future<void> updateName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    _userName = newName;
    await prefs.setString(AppConstants.keyUserName, newName);
    notifyListeners();
  }
}

/// Provider para gerenciar favoritos
/// 
/// Mantém lista de unidades favoritadas e fornece
/// métodos para adicionar/remover favoritos
class FavoritesProvider with ChangeNotifier {
  final List<int> _favoriteIds = [];
  
  List<int> get favoriteIds => _favoriteIds;

  /// Carrega favoritos do banco de dados
  Future<void> loadFavorites(int userId) async {
    final dbHelper = DatabaseHelper();
    final favorites = await dbHelper.getUserFavorites(userId);
    _favoriteIds.clear();
    _favoriteIds.addAll(favorites.map((f) => f['unit_id'] as int));
    notifyListeners();
  }

  /// Verifica se uma unidade está nos favoritos
  bool isFavorite(int unitId) {
    return _favoriteIds.contains(unitId);
  }

  /// Adiciona/remove favorito
  Future<void> toggleFavorite(int userId, int unitId) async {
    final dbHelper = DatabaseHelper();
    
    if (_favoriteIds.contains(unitId)) {
      await dbHelper.removeFavorite(userId, unitId);
      _favoriteIds.remove(unitId);
    } else {
      await dbHelper.addFavorite(userId, unitId);
      _favoriteIds.add(unitId);
    }
    
    notifyListeners();
  }

  /// Limpa todos os favoritos (usado no logout)
  void clearFavorites() {
    _favoriteIds.clear();
    notifyListeners();
  }
}