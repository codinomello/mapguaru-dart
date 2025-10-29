import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/theme.dart'; // <<< ADICIONADO

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false; // <<< ADICIONADO

  Future<void> _sendPasswordResetEmail() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar(context, "Por favor, insira seu e-mail.", isError: true);
      return;
    }

    setState(() => _isLoading = true); // <<< ADICIONADO

    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      _showSnackBar(context, 
        "Link de redefinição enviado para $email. Verifique sua caixa de entrada.", 
        isError: false
      );
      
      if (mounted) Navigator.of(context).pop();

    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = "Ocorreu um erro. Verifique se o e-mail está correto e tente novamente."; 
      } else {
        message = e.message ?? "Erro desconhecido ao enviar o e-mail.";
      }
      _showSnackBar(context, message, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // <<< ADICIONADO
      }
    }
  }

  // <<< ALTERADO: Padronizado com os outros SnackBar
  void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
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
      appBar: AppBar(title: Text('Esqueci a Senha')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            const Text('Informe seu e-mail para redefinir a senha:'),
            const SizedBox(height: 15),
            // <<< ALTERADO: TextFormField padronizado com o tema
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'Digite seu e-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20),
            // <<< ALTERADO: ElevatedButton padronizado com o tema
            ElevatedButton(
              onPressed: _isLoading ? null : _sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isLoading 
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Enviar Link de Redefinição'),
            ),
          ],
        ),
      ),
    );
  }
}