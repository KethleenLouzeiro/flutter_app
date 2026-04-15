import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _isLoading = false;

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      /// 🔥 CRIA USUÁRIO NO FIREBASE
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      /// 🔥 SALVA NOME DO USUÁRIO
      await userCredential.user!.updateDisplayName(
        _nomeController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      /// VOLTA PARA LOGIN
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String erro = 'Erro ao cadastrar';

      if (e.code == 'email-already-in-use') {
        erro = 'Email já está em uso';
      } else if (e.code == 'weak-password') {
        erro = 'Senha muito fraca';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _decoracaoCampo(String texto) {
    return InputDecoration(
      hintText: texto,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nomeController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// EMAIL
              TextFormField(
                controller: _emailController,
                decoration: _decoracaoCampo('Email'),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Digite o email';
                  }
                  if (!v.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// NOME
              TextFormField(
                controller: _nomeController,
                decoration: _decoracaoCampo('Nome'),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Digite o nome';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// SENHA
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: _decoracaoCampo('Senha'),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// CONFIRMAR SENHA
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: true,
                decoration: _decoracaoCampo('Confirmar senha'),
                validator: (v) {
                  if (v != _senhaController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              /// BOTÃO
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _cadastrar,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}