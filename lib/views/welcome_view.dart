import 'package:flutter/material.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [

          // 🔹 IMAGEM DE FUNDO
          Positioned.fill(
            child: Image.asset(
              'assets/images/planodefundo.png', 
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // 🔹 CONTEÚDO DA TELA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                       const SizedBox(height: 5),
                        Center(
                        child: Image.asset(
                       'assets/images/logotipo.png',
                       width: 195,
                    ),
                     ),

                  const SizedBox(height: 66),

                  const Text(
                    "Boas Vindas!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255), // melhor leitura no fundo
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    decoration: InputDecoration(
                      hintText: "Digite seu e-mail ou Telefone",
                      filled: true,
                      fillColor: Colors.white.withValues(alpha:0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white.withValues(alpha:0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Esqueceu a senha?",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

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
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        "ENTRAR",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  ),
),

                  const SizedBox(height: 100),

                  const Spacer(),

                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Não tem uma conta? Cadastre-se",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}