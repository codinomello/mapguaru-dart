import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Serviço centralizado de autenticação
/// 
/// Gerencia autenticação via Firebase (Google, Facebook, GitHub),
/// autenticação biométrica local e gerenciamento de sessão
class AuthService with ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  firebase_auth.User? _user;
  firebase_auth.User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthService() {
    // Monitora mudanças no estado de autenticação
    _firebaseAuth.authStateChanges().listen((firebase_auth.User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // ==================== AUTENTICAÇÃO COM EMAIL/SENHA ====================
  
  /// Faz login com email e senha
  Future<firebase_auth.UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      notifyListeners();
      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Erro no login: ${e.code}');
      _handleAuthException(e);
      return null;
    }
  }

  /// Cria conta com email e senha
  Future<firebase_auth.UserCredential?> createUserWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Atualiza nome do usuário
      await credential.user?.updateDisplayName(displayName);
      
      _user = credential.user;
      notifyListeners();
      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Erro no cadastro: ${e.code}');
      _handleAuthException(e);
      return null;
    }
  }

  /// Envia email de recuperação de senha
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Email de recuperação enviado');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Erro ao enviar email: ${e.code}');
      _handleAuthException(e);
      return false;
    }
  }

  // ==================== AUTENTICAÇÃO SOCIAL ====================

  /// Login com Google
  Future<firebase_auth.UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('🔐 Iniciando login com Google...');
      
      final provider = firebase_auth.GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');

      final credential = kIsWeb
          ? await _firebaseAuth.signInWithPopup(provider)
          : await _firebaseAuth.signInWithProvider(provider);

      _user = credential.user;
      notifyListeners();
      
      debugPrint('✅ Login com Google bem-sucedido');
      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Erro no login com Google: ${e.code}');
      _handleAuthException(e);
      return null;
    } catch (e, stack) {
      debugPrint('❌ Erro inesperado no login com Google: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  /// Login com Facebook
  Future<firebase_auth.UserCredential?> signInWithFacebook() async {
    try {
      debugPrint('🔐 Iniciando login com Facebook...');
      
      final provider = firebase_auth.FacebookAuthProvider();
      provider.addScope('email');
      provider.addScope('public_profile');

      final credential = kIsWeb
          ? await _firebaseAuth.signInWithPopup(provider)
          : await _firebaseAuth.signInWithProvider(provider);

      _user = credential.user;
      notifyListeners();
      
      debugPrint('✅ Login com Facebook bem-sucedido');
      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Erro no login com Facebook: ${e.code}');
      _handleAuthException(e);
      return null;
    } catch (e, stack) {
      debugPrint('❌ Erro inesperado no login com Facebook: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  /// Login com GitHub
  Future<firebase_auth.UserCredential?> signInWithGitHub() async {
    try {
      debugPrint('🔐 Iniciando login com GitHub...');
      
      final provider = firebase_auth.GithubAuthProvider();
      provider.addScope('user:email');
      provider.addScope('read:user');

      final credential = kIsWeb
          ? await _firebaseAuth.signInWithPopup(provider)
          : await _firebaseAuth.signInWithProvider(provider);

      _user = credential.user;
      notifyListeners();
      
      debugPrint('✅ Login com GitHub bem-sucedido');
      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Erro no login com GitHub: ${e.code}');
      _handleAuthException(e);
      return null;
    } catch (e, stack) {
      debugPrint('❌ Erro inesperado no login com GitHub: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }
  // ==================== GERENCIAMENTO DE SESSÃO ====================

  /// Faz logout
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _user = null;
      notifyListeners();
      debugPrint('✅ Logout realizado');
    } catch (e, stack) {
      debugPrint('❌ Erro ao fazer logout: $e');
      debugPrint('Stack: $stack');
    }
  }

  /// Recarrega dados do usuário atual
  Future<void> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      _user = _firebaseAuth.currentUser;
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Erro ao recarregar usuário: $e');
    }
  }

  /// Atualiza nome do usuário
  Future<bool> updateDisplayName(String displayName) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
      await reloadUser();
      debugPrint('✅ Nome atualizado');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar nome: $e');
      return false;
    }
  }

  /// Atualiza email do usuário (requer reautenticação recente)
  Future<bool> updateEmail(String newEmail) async {
    try {
      await _firebaseAuth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      await reloadUser();
      debugPrint('✅ Email de verificação enviado');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Erro ao atualizar email: ${e.code}');
      _handleAuthException(e);
      return false;
    }
  }

  /// Atualiza senha do usuário
  Future<bool> updatePassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
      debugPrint('✅ Senha atualizada');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Erro ao atualizar senha: ${e.code}');
      _handleAuthException(e);
      return false;
    }
  }

  /// Deleta conta do usuário
  Future<bool> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
      _user = null;
      notifyListeners();
      debugPrint('✅ Conta deletada');
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ Erro ao deletar conta: ${e.code}');
      _handleAuthException(e);
      return false;
    }
  }

  // ==================== TRATAMENTO DE ERROS ====================

  /// Trata exceções do Firebase Auth
  void _handleAuthException(firebase_auth.FirebaseAuthException e) {
    String message;
    
    switch (e.code) {
      case 'user-not-found':
        message = 'Usuário não encontrado';
        break;
      case 'wrong-password':
        message = 'Senha incorreta';
        break;
      case 'email-already-in-use':
        message = 'Email já está em uso';
        break;
      case 'invalid-email':
        message = 'Email inválido';
        break;
      case 'weak-password':
        message = 'Senha muito fraca';
        break;
      case 'user-disabled':
        message = 'Usuário desabilitado';
        break;
      case 'too-many-requests':
        message = 'Muitas tentativas. Tente novamente mais tarde';
        break;
      case 'operation-not-allowed':
        message = 'Operação não permitida';
        break;
      case 'account-exists-with-different-credential':
        message = 'Conta já existe com credencial diferente';
        break;
      case 'requires-recent-login':
        message = 'Operação sensível. Faça login novamente';
        break;
      default:
        message = e.message ?? 'Erro de autenticação';
    }
    
    debugPrint('ℹ️ Mensagem de erro: $message');
  }

  /// Retorna mensagem de erro amigável
  String getErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já está em uso';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'user-disabled':
        return 'Usuário desabilitado';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      default:
        return 'Erro ao autenticar. Tente novamente';
    }
  }
}