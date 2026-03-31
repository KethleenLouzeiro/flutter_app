import 'package:flutter/material.dart';
import 'package:flutter_app/views/cadastro_view.dart';

class LoginBoasVindasView extends StatelessWidget {
  const LoginBoasVindasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              /// LOGO
              // Expanded(
              //   flex: 2,
              //   child: Center(
              //     child: Image.asset(
              //       'assets/images/logo.png',
              //       fit: BoxFit.contain,
              //     ),
              //   ),
              // ),

              /// TEXTO
              const Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bem-vindo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Seu app começa aqui 🚀',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              //     // TextFormField(
              //     //       controller: _confirmarSenhaController,
              //     //       obscureText: true,
              //     //       decoration: _decoracaoCampo('Confirmação de Senha'),
              //     //       validator: (v) {
              //     //         if (v != _senhaController.text) {
              //     //           return 'As senhas não coincidem';
              //     //         }
              //     //         return null;
              //           },
              //         ),
              //     ),
              // ),
              /// BOTÕES
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// BOTÃO ENTRAR
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // navegar para login
                          },
                          child: const Text(
                            'Entrar',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// BOTÃO CADASTRAR
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CadastroView()),
                          );
                          },
                          child: const Text(
                            'Criar conta',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}