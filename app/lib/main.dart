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
import 'screens/main_menu_screen.dart';
import 'screens/category_detail_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/service_guide_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Inicializa o Firebase (com tratamento de erro)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Erro ao inicializar Firebase: $e');
  }

  // 🔒 Bloqueia a orientação do app em retrato
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 🧩 Inicializa banco local e dados da API
  final dbHelper = DatabaseHelper();
  await _initializeDataFromAPI(dbHelper); // 🆕 NOVA FUNÇÃO

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

/// 🆕 NOVA FUNÇÃO: Carrega dados reais da API do GeoServer
Future<void> _initializeDataFromAPI(DatabaseHelper dbHelper) async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool(AppConstants.keyFirstTime) ?? true;
  final lastUpdate = prefs.getString(AppConstants.keyLastDataUpdate);
  
  // Define se precisa atualizar (primeira vez ou passaram mais de 7 dias)
  bool needsUpdate = isFirstTime;
  
  if (!isFirstTime && lastUpdate != null) {
    final lastUpdateDate = DateTime.parse(lastUpdate);
    final daysSinceUpdate = DateTime.now().difference(lastUpdateDate).inDays;
    needsUpdate = daysSinceUpdate > 7; // Atualiza a cada 7 dias
  }

  if (needsUpdate) {
    debugPrint('🔄 Atualizando dados da API do GeoServer...');
    
    try {
      // 1️⃣ Primeiro, tenta buscar camadas disponíveis
      final availableLayers = await GeoNetworkService.getWMSLayers();
      debugPrint('📋 Camadas disponíveis: ${availableLayers.join(", ")}');
      
      // 2️⃣ Busca todos os dados das camadas
      final units = await GeoNetworkService.fetchAllServiceUnits();
      
      if (units.isNotEmpty) {
        // 3️⃣ Limpa dados antigos (opcional - pode causar perda de favoritos)
        // await dbHelper.clearAllServiceUnits();
        
        // 4️⃣ Insere novos dados
        int insertedCount = 0;
        for (var unit in units) {
          try {
            await dbHelper.insertServiceUnit(unit);
            insertedCount++;
          } catch (e) {
            debugPrint('⚠️ Erro ao inserir unidade: $e');
          }
        }
        
        debugPrint('✅ $insertedCount unidades inseridas no banco local');
        
        // 5️⃣ Atualiza data da última sincronização
        await prefs.setString(
          AppConstants.keyLastDataUpdate, 
          DateTime.now().toIso8601String(),
        );
      } else {
        debugPrint('⚠️ Nenhum dado foi retornado da API');
        
        // Se for primeira vez e não conseguiu dados, usa dados de exemplo
        if (isFirstTime) {
          debugPrint('📦 Usando dados de exemplo como fallback...');
          await _insertSampleData(dbHelper);
        }
      }
      
    } catch (e) {
      debugPrint('❌ Erro ao buscar dados da API: $e');
      
      // Se for primeira vez e houve erro, usa dados de exemplo
      if (isFirstTime) {
        debugPrint('📦 Usando dados de exemplo como fallback...');
        await _insertSampleData(dbHelper);
      }
    }
    
    await prefs.setBool(AppConstants.keyFirstTime, false);
  } else {
    debugPrint('✓ Dados já estão atualizados');
  }
}

/// Fallback: insere dados de exemplo se API falhar
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
      initialRoute: AppConstants.routeSplash,
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

class UserProvider with ChangeNotifier {
  int? _userId;
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;

  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;

  /// 🔹 Carrega dados locais do usuário
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt(AppConstants.keyUserId);
    _userName = prefs.getString(AppConstants.keyUserName);
    _userEmail = prefs.getString(AppConstants.keyUserEmail);
    _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    notifyListeners();
  }

  /// 🔹 Login persistente
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

  /// 🔹 Logout completo
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

    // Sai também do Firebase
    await FirebaseAuth.instance.signOut();

    notifyListeners();
  }

  /// 🔹 Atualiza nome local
  Future<void> updateName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    _userName = newName;
    await prefs.setString(AppConstants.keyUserName, newName);
    notifyListeners();
  }
}

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