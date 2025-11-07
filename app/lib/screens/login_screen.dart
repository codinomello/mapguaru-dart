import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../database/database_helper.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../main.dart';

/// Tela de login com suporte a autenticação tradicional e social
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==================== VALIDAÇÕES ====================

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite seu email';
    }
    final emailRegex = RegExp(AppConstants.emailRegex);
    if (!emailRegex.hasMatch(value)) {
      return AppConstants.errorEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite sua senha';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return AppConstants.errorPasswordShort;
    }
    return null;
  }

  // ==================== AUTENTICAÇÃO TRADICIONAL ====================

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.loginUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        await _completeLogin(
          userId: user['user_id'] as int,
          name: user['name'] as String,
          email: user['email'] as String,
        );
      } else {
        _showSnackBar(AppConstants.errorLoginFailed);
      }
    } catch (e) {
      _showSnackBar(AppConstants.errorGeneric);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==================== AUTENTICAÇÃO SOCIAL ====================

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final credential = await authService.signInWithGoogle();

      if (credential != null && mounted) {
        await _handleFirebaseLogin(credential.user!);
      } else if (mounted) {
        _showSnackBar('Falha no login com Google');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao fazer login com Google');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookLogin() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final credential = await authService.signInWithFacebook();

      if (credential != null && mounted) {
        await _handleFirebaseLogin(credential.user!);
      } else if (mounted) {
        _showSnackBar('Falha no login com Facebook');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao fazer login com Facebook');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGitHubLogin() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final credential = await authService.signInWithGitHub();

      if (credential != null && mounted) {
        await _handleFirebaseLogin(credential.user!);
      } else if (mounted) {
        _showSnackBar('Falha no login com GitHub');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao fazer login com GitHub');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Processa login via Firebase Auth
  Future<void> _handleFirebaseLogin(firebase_auth.User firebaseUser) async {
    try {
      final dbHelper = DatabaseHelper();
      
      // Verifica se usuário já existe no banco local
      var localUser = await dbHelper.loginUser(
        firebaseUser.email!,
        '', // Senha vazia para login social
      );

      // Se não existe, cria no banco local
      if (localUser == null) {
        final userId = await dbHelper.registerUser(
          firebaseUser.displayName ?? 'Usuário',
          firebaseUser.email!,
          '', // Senha vazia para login social
        );

        if (userId != null) {
          localUser = {
            'user_id': userId,
            'name': firebaseUser.displayName ?? 'Usuário',
            'email': firebaseUser.email!,
          };
        }
      }

      if (localUser != null && mounted) {
        await _completeLogin(
          userId: localUser['user_id'] as int,
          name: localUser['name'] as String,
          email: localUser['email'] as String,
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao sincronizar usuário');
    }
  }

  // ==================== FINALIZAÇÃO DO LOGIN ====================

  Future<void> _completeLogin({
    required int userId,
    required String name,
    required String email,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.login(userId, name, email);

    final favoritesProvider = Provider.of<FavoritesProvider>(
      context,
      listen: false,
    );
    await favoritesProvider.loadFavorites(userId);

    if (mounted) {
      _showSnackBar(AppConstants.successLogin, isError: false);

      Navigator.of(context).pushReplacementNamed(
        AppConstants.routeMainMenu,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==================== INTERFACE ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    /// Ícone do app
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Título
                    Text(
                      'Bem-vindo de volta!',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    /// Subtítulo
                    Text(
                      'Faça login para acessar seus favoritos',
                      style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    /// Campo de email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'Digite seu e-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 16),

                    /// Campo de senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Digite sua senha',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: _validatePassword,
                    ),

                    const SizedBox(height: 8),

                    /// Link esqueci a senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            '/forgot-password',
                          );
                        },
                        child: const Text(
                          'Esqueci a senha',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Botão de login
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: const Text('Fazer login'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Link para cadastro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Não tem uma conta? ',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed(
                              AppConstants.routeRegister,
                            );
                          },
                          child: const Text(
                            'Cadastre-se',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    /// Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU ENTRE COM',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              color: Theme.of(context).iconTheme.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// Botões de login social
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          icon: Icons.g_mobiledata,
                          label: 'Google',
                          color: const Color(0xFFDB4437),
                          onTap: _handleGoogleLogin,
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          color: const Color(0xFF4267B2),
                          onTap: _handleFacebookLogin,
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          icon: Icons.code,
                          label: 'GitHub',
                          color: const Color(0xFF333333),
                          onTap: _handleGitHubLogin,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          
          /// Overlay de loading
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Widget de botão social
  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: _isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(
              icon,
              size: 30,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}