import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../main.dart';

/// Tela para converter conta anônima em permanente
class UpgradeAccountScreen extends StatefulWidget {
  const UpgradeAccountScreen({super.key});

  @override
  State<UpgradeAccountScreen> createState() => _UpgradeAccountScreenState();
}

class _UpgradeAccountScreenState extends State<UpgradeAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _upgradeMethod = 'email'; // 'email', 'google', 'facebook', 'github'

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite seu nome completo';
    }
    if (value.length < 3) {
      return 'Nome deve ter no mínimo 3 caracteres';
    }
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }
    if (value != _passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  /// Converte conta usando email/senha
  Future<void> _upgradeWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Vincula conta anônima com email/senha
      final credential = await authService.linkAnonymousWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (credential != null && mounted) {
        // Atualiza banco local
        final dbHelper = DatabaseHelper();
        final userId = await dbHelper.registerUser(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (userId != null) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          await userProvider.login(
            userId,
            _nameController.text.trim(),
            _emailController.text.trim(),
          );

          _showSnackBar('Conta convertida com sucesso!', isError: false);

          Navigator.of(context).pushNamedAndRemoveUntil(
            AppConstants.routeMainMenu,
            (route) => false,
          );
        }
      } else if (mounted) {
        _showSnackBar('Erro ao converter conta');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao converter conta: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Converte conta usando Google
  Future<void> _upgradeWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Cria provider do Google
      final googleProvider = firebase_auth.GoogleAuthProvider();
      
      // Vincula conta anônima com Google
      final credential = await authService.linkAnonymousWithProvider(googleProvider);

      if (credential != null && mounted) {
        await _handleSocialUpgrade(credential.user!);
      } else if (mounted) {
        _showSnackBar('Erro ao converter conta com Google');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao converter com Google');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Converte conta usando Facebook
  Future<void> _upgradeWithFacebook() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final facebookProvider = firebase_auth.FacebookAuthProvider();
      final credential = await authService.linkAnonymousWithProvider(facebookProvider);

      if (credential != null && mounted) {
        await _handleSocialUpgrade(credential.user!);
      } else if (mounted) {
        _showSnackBar('Erro ao converter conta com Facebook');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao converter com Facebook');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Converte conta usando GitHub
  Future<void> _upgradeWithGitHub() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final githubProvider = firebase_auth.GithubAuthProvider();
      final credential = await authService.linkAnonymousWithProvider(githubProvider);

      if (credential != null && mounted) {
        await _handleSocialUpgrade(credential.user!);
      } else if (mounted) {
        _showSnackBar('Erro ao converter conta com GitHub');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao converter com GitHub');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Processa upgrade via provedor social
  Future<void> _handleSocialUpgrade(firebase_auth.User firebaseUser) async {
    try {
      final dbHelper = DatabaseHelper();
      
      // Registra no banco local
      final userId = await dbHelper.registerUser(
        firebaseUser.displayName ?? 'Usuário',
        firebaseUser.email!,
        '',
      );

      if (userId != null && mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.login(
          userId,
          firebaseUser.displayName ?? 'Usuário',
          firebaseUser.email!,
        );

        _showSnackBar('Conta convertida com sucesso!', isError: false);

        Navigator.of(context).pushNamedAndRemoveUntil(
          AppConstants.routeMainMenu,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao sincronizar usuário');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta Permanente'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.upgrade,
                    size: 40,
                    color: AppTheme.accentColor,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Salve seu progresso!',
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
                'Crie uma conta permanente para não perder seus favoritos e configurações.',
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Abas de método
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'email',
                    label: Text('Email'),
                    icon: Icon(Icons.email),
                  ),
                  ButtonSegment(
                    value: 'social',
                    label: Text('Social'),
                    icon: Icon(Icons.people),
                  ),
                ],
                selected: {_upgradeMethod},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _upgradeMethod = newSelection.first;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Conteúdo baseado no método
              if (_upgradeMethod == 'email')
                _buildEmailForm()
              else
                _buildSocialOptions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Formulário de email/senha
  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nome completo',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: _validateName,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-mail',
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

          const SizedBox(height: 16),

          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar senha',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
            ),
            validator: _validateConfirmPassword,
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _upgradeWithEmail,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Criar Conta'),
            ),
          ),
        ],
      ),
    );
  }

  /// Opções sociais
  Widget _buildSocialOptions() {
    return Column(
      children: [
        _buildSocialButton(
          'Continuar com Google',
          Icons.g_mobiledata,
          const Color(0xFFDB4437),
          _upgradeWithGoogle,
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          'Continuar com Facebook',
          Icons.facebook,
          const Color(0xFF4267B2),
          _upgradeWithFacebook,
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          'Continuar com GitHub',
          Icons.code,
          const Color(0xFF333333),
          _upgradeWithGitHub,
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}