import 'package:flutter/material.dart';
import 'cadastro_view.dart';
import 'dashboard_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    try {
      // 🔥 AQUI VAI ENTRAR O FIREBASE DEPOIS
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: senha,
);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login realizado: $email')),
      );

      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardView(),
      ),
);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao fazer login')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _background(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _header(),
                _form(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _background({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF1E293B),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }

  Widget _header() {
    return const Expanded(
      flex: 1,
      child: Center(
        child: Text(
          'Login',
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// EMAIL
            TextFormField(
              controller: _emailController,
              decoration: _inputStyle('Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite seu email';
                }
                if (!value.contains('@')) {
                  return 'Email inválido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            /// SENHA
            TextFormField(
              controller: _senhaController,
              obscureText: true,
              decoration: _inputStyle('Senha'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite sua senha';
                }
                if (value.length < 6) {
                  return 'Mínimo 6 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            /// BOTÃO LOGIN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Entrar'),
              ),
            ),

            const SizedBox(height: 16),

            /// IR PARA CADASTRO
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CadastroView(),
                  ),
                );
              },
              child: const Text(
                'Criar conta',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}