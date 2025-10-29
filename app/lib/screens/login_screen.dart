import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:local_auth/local_auth.dart'; // Necessário para biometria real
import '../database/database_helper.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../main.dart';
import 'forgot_password_screen.dart'; // Assumindo que este arquivo exista

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
  bool _canUseBiometric = false; // Estado para biometria

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  /// Verifica se a biometria está disponível
  Future<void> _checkBiometric() async {
    // Em um app real, você usaria o plugin 'local_auth':
    // final LocalAuthentication auth = LocalAuthentication();
    // final bool canCheck = await auth.canCheckBiometrics;
    // final bool isSupported = await auth.isDeviceSupported();
    // if (mounted) {
    //   setState(() {
    //     _canUseBiometric = canCheck || isSupported;
    //   });
    // }

    // Mock para fins de UI (simula que a biometria está disponível):
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() {
        _canUseBiometric = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.login(
          user['user_id'] as int,
          user['name'] as String,
          user['email'] as String,
        );

        final favoritesProvider = Provider.of<FavoritesProvider>(
          context,
          listen: false,
        );
        await favoritesProvider.loadFavorites(user['user_id'] as int);

        _showSnackBar(AppConstants.successLogin, isError: false);

        Navigator.of(context).pushReplacementNamed(
          AppConstants.routeMainMenu,
        );
      } else {
        _showSnackBar(AppConstants.errorLoginFailed);
      }
    } catch (e) {
      _showSnackBar(AppConstants.errorGeneric);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Handlers para Login Social (Mocks) ---
  Future<void> _handleGoogleLogin() async {
    _showSnackBar('Login com Google em desenvolvimento', isError: false);
  }

  Future<void> _handleFacebookLogin() async {
    _showSnackBar('Login com Facebook em desenvolvimento', isError: false);
  }

  Future<void> _handleBiometricLogin() async {
    // Lógica real com 'local_auth':
    // final LocalAuthentication auth = LocalAuthentication();
    // try {
    //   final bool didAuthenticate = await auth.authenticate(
    //     localizedReason: 'Por favor, autentique-se para fazer login',
    //   );
    //   if (didAuthenticate) {
    //     // Lógica de login após sucesso biométrico
    //   }
    // } catch (e) {
    //   _showSnackBar('Erro na autenticação biométrica');
    // }
    _showSnackBar('Login com Biometria em desenvolvimento', isError: false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        elevation: 0,
      ),
      // Stack para o overlay de loading
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
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: _validatePassword,
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Navega para a tela de esquecer senha
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
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

                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        // Texto simples, o loading agora é um overlay
                        child: const Text('Fazer login'),
                      ),
                    ),

                    const SizedBox(height: 24),

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

                    // --- SEÇÃO DE LOGIN SOCIAL ADICIONADA ---
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
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
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          // Ícone do Google (idealmente seria uma imagem)
                          icon: Icons.g_mobiledata,
                          label: 'Google',
                          color: const Color(0xFFDB4437),
                          onTap: _handleGoogleLogin,
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          color: const Color(0xFF4267B2),
                          onTap: _handleFacebookLogin,
                        ),
                        if (_canUseBiometric)
                          const SizedBox(width: 20),
                        if (_canUseBiometric)
                          _buildSocialButton(
                            icon: Icons.fingerprint,
                            label: 'Biometria',
                            color: AppTheme.success,
                            onTap: _handleBiometricLogin,
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // --- FIM DA SEÇÃO SOCIAL ---
                  ],
                ),
              ),
            ),
          ),
          // Overlay de carregamento em tela cheia
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

  /// Widget auxiliar para criar os botões de login social
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