import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// Tela de recuperação de senha via email
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Valida formato do email
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

  /// Envia email de recuperação
  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        setState(() => _emailSent = true);
        _showSnackBar(
          'Link de redefinição enviado para ${_emailController.text.trim()}',
          isError: false,
        );
      } else {
        _showSnackBar(
          'Erro ao enviar email. Verifique se o email está correto',
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao enviar email de recuperação: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        title: const Text('Recuperar Senha'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                /// Ícone
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _emailSent
                          ? AppTheme.success.withOpacity(0.1)
                          : AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _emailSent ? Icons.check_circle : Icons.lock_reset,
                      size: 40,
                      color: _emailSent ? AppTheme.success : AppTheme.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Título
                Text(
                  _emailSent ? 'Email Enviado!' : 'Esqueceu a senha?',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                /// Descrição
                Text(
                  _emailSent
                      ? 'Enviamos um link de recuperação para seu email. Verifique sua caixa de entrada e spam.'
                      : 'Digite seu email cadastrado e enviaremos um link para redefinir sua senha.',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                if (!_emailSent) ...[
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

                  const SizedBox(height: 24),

                  /// Botão enviar
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendResetEmail,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Enviar Link de Recuperação'),
                    ),
                  ),
                ] else ...[
                  /// Botão voltar ao login
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Voltar ao Login'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Botão reenviar
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _emailSent = false);
                      },
                      child: const Text('Enviar Novamente'),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                /// Dicas
                if (!_emailSent)
                  Card(
                    color: AppTheme.info.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.info,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Dica',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'O link de recuperação é válido por 1 hora. Se não receber o email, verifique sua pasta de spam ou lixo eletrônico.',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}