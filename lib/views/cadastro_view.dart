import 'package:flutter/material.dart';

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

  void _cadastrar() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
        ),
      );
    }
  }

  InputDecoration _decoracaoCampo(String texto) {
    return InputDecoration(
      labelText: texto,
      
      filled:true,
      fillColor: Colors.white.withValues(alpha:0.8),

      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.grey),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          

          /// IMAGEM DE FUNDO
          Positioned.fill(
            child: Image.asset(
              'assets/images/planodefundo.png',
              fit: BoxFit.cover,
            ),
          ),





          /// CONTEÚDO DA TELA
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      const SizedBox(height:2),

                      Center(
                        child:Image.asset('assets/images/logotipo.png',
                        width:150),
                      ),

                      const SizedBox(height:41),
         
                      /// EMAIL
                      TextFormField(
                        controller: _emailController,
                        decoration: _decoracaoCampo('Digite seu e-mail'),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Digite seu e-mail';
                          }
                          if (!v.contains('@')) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// NOME
                      TextFormField(
                        controller: _nomeController,
                        decoration: _decoracaoCampo('Nome de Usuário'),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Digite seu nome';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// SENHA
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: _decoracaoCampo('Senha'),
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return 'Senha mínima de 6 caracteres';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// CONFIRMAR SENHA
                      TextFormField(
                        controller: _confirmarSenhaController,
                        obscureText: true,
                        decoration: _decoracaoCampo('Confirmação de Senha'),
                        validator: (v) {
                          if (v != _senhaController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// BOTÃO
SizedBox(
  width: double.infinity,
  height: 55,
  child: Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF6366F1),
          Color(0xFF3B82F6),
        ],
      ),
      borderRadius: BorderRadius.circular(30),
    ),
    child: ElevatedButton(
      onPressed: () {
        _cadastrar();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "CADASTRA-SE",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  ),
)
 
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
