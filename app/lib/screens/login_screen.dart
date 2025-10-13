import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../main.dart';

/// Tela de login do usuário
/// 
/// Permite autenticação com email e senha
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Valida email
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

  /// Valida senha
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite sua senha';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return AppConstants.errorPasswordShort;
    }
    return null;
  }

  /// Realiza login
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
        // Login bem-sucedido
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.login(
          user['user_id'] as int,
          user['name'] as String,
          user['email'] as String,
        );

        // Carregar favoritos
        final favoritesProvider = Provider.of<FavoritesProvider>(
          context,
          listen: false,
        );
        await favoritesProvider.loadFavorites(user['user_id'] as int);

        // Mostrar mensagem de sucesso
        _showSnackBar(AppConstants.successLogin, isError: false);

        // Navegar para menu principal
        Navigator.of(context).pushReplacementNamed(
          AppConstants.routeMainMenu,
        );
      } else {
        // Falha no login
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

  /// Mostra SnackBar
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // Ícone
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
              
              const SizedBox(height: 32),
              
              // Título
              const Text(
                'Bem-vindo de volta!',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Faça login para acessar seus favoritos',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Campo Email
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
              
              // Campo Senha
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
              
              // Link: Esqueci a senha
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Implementar recuperação de senha
                    _showSnackBar(
                      'Funcionalidade em desenvolvimento',
                      isError: false,
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
              
              // Botão Login
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Fazer login'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Link para cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Não tem uma conta? ',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      color: AppTheme.textSecondary,
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
            ],
          ),
        ),
      ),
    );
  }
}