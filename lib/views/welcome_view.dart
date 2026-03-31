import 'package:flutter/material.dart';
import 'cadastro_view.dart';
import 'dashboard_view.dart';
import 'Postos_view.dart';
import 'pontosturisticos_view.dart';
// import 'oficinas_carros_view.dart';
import 'package:flutter/material.dart';
import 'home_view.dart';
import 'splash_view.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _nomeController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _cadastrar() {
    if (_formKey.currentState!.validate()) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
        ),
      );

      /// 🔥 REDIRECIONA PARA HOME
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeView()),
        );
      });
    }
  }

  InputDecoration _decoracaoCampo(String texto) {
    return InputDecoration(
      hintText: texto,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.white),
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

          /// FUNDO
          Positioned.fill(
            child: Image.asset(
              'assets/images/planodefundo.png',
              fit: BoxFit.cover,
            ),
          ),

          /// CONTEÚDO
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      const SizedBox(height: 10),

                      Image.asset(
                        'assets/images/logotipo.png',
                        width: 150,
                      ),

                      const SizedBox(height: 40),

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
                        decoration:
                            _decoracaoCampo('Confirmação de Senha'),
                        validator: (v) {
                          if (v != _senhaController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// BOTÃO CADASTRAR
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
                            onPressed: _cadastrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "CADASTRAR",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// BOTÃO VOLTAR PARA SPLASH
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SplashView()),
                          );
                        },
                        child: const Text(
                          "Voltar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
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














// class CadastroView extends StatefulWidget {
//   const CadastroView({super.key});

//   @override
//   State<CadastroView> createState() => _CadastroViewState();
// }

// class _CadastroViewState extends State<CadastroView> {
//   final _formKey = GlobalKey<FormState>();

//   final _emailController = TextEditingController();
//   final _nomeController = TextEditingController();
//   final _senhaController = TextEditingController();
//   final _confirmarSenhaController = TextEditingController();

//   void _cadastrar() {
//     if (_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Cadastro realizado com sucesso!'),
//         ),
//       );
//     }
//   }

//   InputDecoration _decoracaoCampo(String texto) {
//     return InputDecoration(
//       hintText: texto,
      
//       filled:true,
//       fillColor: Colors.white,

//       contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),

//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30),
//       ),

//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30),
//         borderSide: const BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
//       ),

//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30),
//         borderSide: const BorderSide(color: Colors.blue),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [

          

//           /// IMAGEM DE FUNDO
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/planodefundo.png',
//               fit: BoxFit.cover,
//             ),
//           ),





//           /// CONTEÚDO DA TELA
//           Padding(
//             padding: const EdgeInsets.all(24),
//             child: Center(
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [

//                       const SizedBox(height:2),

//                       Center(
//                         child:Image.asset('assets/images/logotipo.png',
//                         width:150),
//                       ),

//                       const SizedBox(height:41),
         
//                       /// EMAIL
//                       TextFormField(
//                         controller: _emailController,
//                         decoration: _decoracaoCampo('Digite seu e-mail'),
//                         validator: (v) {
//                           if (v == null || v.isEmpty) {
//                             return 'Digite seu e-mail';
//                           }
//                           if (!v.contains('@')) {
//                             return 'E-mail inválido';
//                           }
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 20),

//                       /// NOME
//                       TextFormField(
//                         controller: _nomeController,
//                         decoration: _decoracaoCampo('Nome de Usuário'),
//                         validator: (v) {
//                           if (v == null || v.isEmpty) {
//                             return 'Digite seu nome';
//                           }
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 20),

//                       /// SENHA
//                       TextFormField(
//                         controller: _senhaController,
//                         obscureText: true,
//                         decoration: _decoracaoCampo('Senha'),
//                         validator: (v) {
//                           if (v == null || v.length < 6) {
//                             return 'Senha mínima de 6 caracteres';
//                           }
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 20),

//                       /// CONFIRMAR SENHA
//                       TextFormField(
//                         controller: _confirmarSenhaController,
//                         obscureText: true,
//                         decoration: _decoracaoCampo('Confirmação de Senha'),
//                         validator: (v) {
//                           if (v != _senhaController.text) {
//                             return 'As senhas não coincidem';
//                           }
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 30),

//                       /// BOTÃO
// SizedBox(
//   width: double.infinity,
//   height: 55,
//   child: Container(
//     decoration: BoxDecoration(
//       gradient: const LinearGradient(
//         colors: [
//           Color(0xFF6366F1),
//           Color(0xFF3B82F6),
//         ],
//       ),
//       borderRadius: BorderRadius.circular(30),
//     ),
//     child: ElevatedButton(
//       onPressed: () {
//         _cadastrar();
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.transparent,
//         shadowColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//         ),
//       ),
//       child: const Text(
//         "CADASTRA-SE",
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//     ),
//   ),
// )
 
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class OnboardingView extends StatelessWidget {
//   const OnboardingView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Container(
//           decoration: const BoxDecoration(
//             //
//           ),
//           child: Column(
//             children: [
//               const Spacer(flex: 2),

//               // Ilustração / ícone principal
//               Container(
//                 padding: const EdgeInsets.all(32),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF6366F1).withOpacity(0.18),
//                       blurRadius: 32,
//                       offset: const Offset(0, 12),
//                     ),
//                   ],
//                 ),

//                 child: const Icon(
//                   Icons.auto_awesome_rounded,
//                   size: 90,
//                   color: Color(0xFF6366F1),
//                 ),
//               ),

//               const SizedBox(height: 40),

//               const Text(
//                 'Pronto para começar?',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 40),
//                 child: Text(
//                   'Crie sua conta para salvar seus dados ou pule e explore o app agora mesmo.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey.shade700,
//                     height: 1.5,
//                   ),
//                 ),
//               ),

//               const Spacer(flex: 3),

//               // Botões
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 32),
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const DashboardView(),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: const Color(0xFF6366F1),
//                           elevation: 2,
//                           side: const BorderSide(
//                             color: Color(0xFF6366F1),
//                             width: 1.5,
//                           ),
//                         ),
//                         child: const Text("Continuar cadastro"),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => GasStationsScreen(),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF6366F1),
//                           foregroundColor: Colors.white,
//                         ),
//                         child: const Text('Postos de combustivel'),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => TouristSpotsScreen(),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color.fromARGB(255, 72, 104, 212),
//                           foregroundColor: Colors.black87,
//                         ),
//                         child: const Text('Pontos Turísticos'),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (_) => const WorkshopsScreen(),
//                           //   ),
//                           // );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color.fromARGB(
//                             255,
//                             77,
//                             115,
//                             218,
//                           ),
//                           foregroundColor: Colors.white,
//                         ),
//                         child: const Text('Oficinas Mecânicas'),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const CadastroView(),
//                             ),
//                           );
//                         },
//                         child: const Text('Criar minha conta'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Spacer(flex: 2),

//               Text(
//                 'Versão didática • Flutter',
//                 style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
