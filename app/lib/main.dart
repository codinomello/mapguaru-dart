import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapguaru/services/geonetwork_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database/database_helper.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/category_detail_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/service_guide_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/news_screen.dart';
import 'screens/city_guide_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado');
  } catch (e) {
    debugPrint('❌ Erro ao inicializar Firebase: $e');
  }

  // Bloqueia orientação em retrato
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializa banco de dados e carrega dados
  final dbHelper = DatabaseHelper();
  await _initializeDataFromAPI(dbHelper);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MapGuaruApp(),
    ),
  );
}

/// Inicializa dados da API do GeoServer
Future<void> _initializeDataFromAPI(DatabaseHelper dbHelper) async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool(AppConstants.keyFirstTime) ?? true;
  final lastUpdate = prefs.getString(AppConstants.keyLastDataUpdate);
  
  bool needsUpdate = isFirstTime;
  
  if (!isFirstTime && lastUpdate != null) {
    final lastUpdateDate = DateTime.parse(lastUpdate);
    final daysSinceUpdate = DateTime.now().difference(lastUpdateDate).inDays;
    needsUpdate = daysSinceUpdate > 7;
  }

  if (needsUpdate) {
    debugPrint('🔄 Atualizando dados da API...');
    
    try {
      // Busca camadas disponíveis
      final availableLayers = await GeoNetworkService.getWMSLayers();
      debugPrint('📋 ${availableLayers.length} camadas WMS encontradas');
      
      // Busca unidades de serviço
      final units = await GeoNetworkService.fetchAllServiceUnits();
      
      if (units.isNotEmpty) {
        int insertedCount = 0;
        
        for (var unit in units) {
          try {
            await dbHelper.insertServiceUnit(unit);
            insertedCount++;
          } catch (e) {
            debugPrint('⚠️ Erro ao inserir unidade: $e');
          }
        }
        
        debugPrint('✅ $insertedCount unidades inseridas');
        
        await prefs.setString(
          AppConstants.keyLastDataUpdate,
          DateTime.now().toIso8601String(),
        );
      } else {
        debugPrint('⚠️ Nenhum dado retornado da API');
        
        if (isFirstTime) {
          debugPrint('📦 Usando dados de exemplo...');
          await _insertSampleData(dbHelper);
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar dados da API: $e');
      
      if (isFirstTime) {
        debugPrint('📦 Usando dados de exemplo...');
        await _insertSampleData(dbHelper);
      }
    }
    
    await prefs.setBool(AppConstants.keyFirstTime, false);
  } else {
    debugPrint('✅ Dados já estão atualizados');
  }
}

/// Insere dados de exemplo como fallback
Future<void> _insertSampleData(DatabaseHelper dbHelper) async {
  for (var unit in AppConstants.sampleServiceUnits) {
    try {
      await dbHelper.insertServiceUnit(unit);
    } catch (e) {
      debugPrint('⚠️ Erro ao inserir dado de exemplo: $e');
    }
  }
  debugPrint('✅ Dados de exemplo inseridos');
}

class MapGuaruApp extends StatelessWidget {
  const MapGuaruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<ThemeProvider>().themeMode,
      initialRoute: AppConstants.routeSplash,
      routes: {
        AppConstants.routeSplash: (context) => const SplashScreen(),
        AppConstants.routeMenu: (context) => const MenuScreen(),
        AppConstants.routeLogin: (context) => const LoginScreen(),
        AppConstants.routeRegister: (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        AppConstants.routeMainMenu: (context) => const MainMenuScreen(),
        AppConstants.routeMap: (context) => const MapScreen(),
        AppConstants.routeProfile: (context) => const ProfileScreen(),
        AppConstants.routeServiceGuide: (context) => const ServiceGuideScreen(),
        AppConstants.routeEmergency: (context) => const EmergencyScreen(),
        AppConstants.routeNews: (context) => const NewsScreen(),
        AppConstants.routeCityGuide: (context) => const CityGuideScreen(),
      },
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

/// Provider de usuário
class UserProvider with ChangeNotifier {
  int? _userId;
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;

  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;

  /// Carrega dados do usuário salvos
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt(AppConstants.keyUserId);
    _userName = prefs.getString(AppConstants.keyUserName);
    _userEmail = prefs.getString(AppConstants.keyUserEmail);
    _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    notifyListeners();
  }

  /// Faz login
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

  /// Faz logout
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

    await FirebaseAuth.instance.signOut();

    notifyListeners();
  }

  /// Atualiza nome
  Future<void> updateName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    _userName = newName;
    await prefs.setString(AppConstants.keyUserName, newName);
    notifyListeners();
  }
}

/// Provider de favoritos
class FavoritesProvider with ChangeNotifier {
  final List<int> _favoriteIds = [];

  List<int> get favoriteIds => _favoriteIds;

  Future<void> loadFavorites(int userId) async {
    final dbHelper = DatabaseHelper();
    final favorites = await dbHelper.getUserFavorites(userId);
    _favoriteIds.clear();
    _favoriteIds.addAll(favorites.map((f) => f['unit_id'] as int));
    notifyListeners();
  }

  bool isFavorite(int unitId) => _favoriteIds.contains(unitId);

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

  void clearFavorites() {
    _favoriteIds.clear();
    notifyListeners();
  }
}