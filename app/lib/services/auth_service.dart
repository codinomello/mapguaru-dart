// services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:local_auth/local_auth.dart'; // Importação essencial
import 'package:flutter/services.dart'; // Necessário para PlatformException

/// Serviço de autenticação com Firebase e Biometria (Local Auth)
///
/// Usa FirebaseAuth para login com Google e Facebook.
class AuthService with ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication(); // Instância do LocalAuth

  firebase_auth.User? _user;
  firebase_auth.User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _firebaseAuth.authStateChanges().listen((firebase_auth.User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // --- MÉTODOS DE AUTENTICAÇÃO PADRÃO (MANTIDOS) ---

  /// 🔹 Login com Email e Senha (Adicionado para completar o LoginScreen)
  Future<firebase_auth.UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      notifyListeners();
      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Erro no login com Email: ${e.code}');
      // Trate códigos de erro específicos aqui (e.g., 'user-not-found', 'wrong-password')
      return null;
    } catch (e) {
      debugPrint('Erro inesperado no login com Email: $e');
      return null;
    }
  }


  /// 🔹 Login com Google (sem `google_sign_in`)
  Future<firebase_auth.UserCredential?> signInWithGoogle() async {
    try {
      final provider = firebase_auth.GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');

      final credential = kIsWeb
          ? await _firebaseAuth.signInWithPopup(provider)
          : await _firebaseAuth.signInWithProvider(provider);

      _user = credential.user;
      notifyListeners();
      return credential;
    } catch (e, stack) {
      debugPrint('Erro no login com Google: $e\n$stack');
      return null;
    }
  }

  /// 🔹 Login com Facebook (sem `flutter_facebook_auth`)
  Future<firebase_auth.UserCredential?> signInWithFacebook() async {
    try {
      final provider = firebase_auth.FacebookAuthProvider();
      provider.addScope('email');
      provider.addScope('public_profile');

      final credential = kIsWeb
          ? await _firebaseAuth.signInWithPopup(provider)
          : await _firebaseAuth.signInWithProvider(provider);

      _user = credential.user;
      notifyListeners();
      return credential;
    } catch (e, stack) {
      debugPrint('Erro no login com Facebook: $e\n$stack');
      return null;
    }
  }

  /// 🔹 Logout
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _user = null;
      notifyListeners();
      debugPrint('Logout concluído com sucesso');
    } catch (e, stack) {
      debugPrint('Erro ao fazer logout: $e\n$stack');
    }
  }

  // --- MÉTODOS DE AUTENTICAÇÃO BIOMÉTRICA (NOVOS) ---

  /// Verifica se o dispositivo pode usar biometria.
  /// (Usado no initState da LoginScreen para mostrar o botão)
  Future<bool> canUseBiometric() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      // Verifica se há biometria registrada no dispositivo E se o dispositivo suporta
      return canAuthenticate && isDeviceSupported;
    } on PlatformException catch (e) {
      debugPrint('Erro ao checar biometria: ${e.message}');
      return false;
    }
  }

  /// 🔹 Autenticação Biométrica
  ///
  /// Retorna `true` se a autenticação for bem-sucedida.
  /// Nota: Esta função apenas autentica o usuário localmente. O login real
  /// (usando Firebase) precisa ser feito APÓS esta autenticação,
  /// provavelmente usando uma credencial salva (como um token ou e-mail/senha)
  /// que deve ser gerenciada pelo seu `UserProvider` e `SharedPreferences`.
  Future<bool> authenticateWithBiometric() async {
    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Confirme sua identidade para acessar o MapGuaru', // Mensagem mostrada ao usuário
      );
      return authenticated;
    } on PlatformException catch (e) {
      debugPrint('Erro na autenticação biométrica: ${e.message}');
      // Trate erros de plataforma (ex: usuário cancelou, biometria não configurada)
      return false;
    }
  }
}