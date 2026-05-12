import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'dashboard_view.dart';

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
  bool _aceitouTermos = false;

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    /// 🔥 TERMOS
    if (!_aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aceite os termos para continuar',
          ),
        ),
      );
      return;
    }

    /// 🔥 SENHAS DIFERENTES
    if (_senhaController.text !=
        _confirmarSenhaController.text) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'As senhas não coincidem',
          ),
        ),
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      await userCredential.user!.updateDisplayName(
        _nomeController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastro realizado com sucesso!',
          ),
        ),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      String erro = 'Erro ao cadastrar';

      /// 🔥 EMAIL JÁ EXISTE
      if (e.code == 'email-already-in-use') {
        erro = 'Email já está em uso';

      /// 🔥 SENHA FRACA
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
      fillColor: Colors.white.withOpacity(0.92),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 2,
        ),
      ),

      errorStyle: const TextStyle(
        height: 0,
        color: Colors.transparent,
      ),

      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20),
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
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [

          /// 🔥 FUNDO
          Positioned.fill(
            child: Image.asset(
              'assets/images/planodesfoque.png',
              fit: BoxFit.cover,
            ),
          ),

          /// 🔥 OVERLAY
          Container(
            color: Colors.black.withOpacity(0.35),
          ),

          SafeArea(
            child: Form(
              key: _formKey,

              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 12,
                    bottom: MediaQuery.of(context)
                        .viewInsets
                        .bottom,
                  ),

                  child: Column(
                    children: [

                      /// 🔙 VOLTAR
                      Row(
                        children: [

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),

                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },

                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 0.1),

                      /// 🔥 LOGO
                      Image.asset(
                        'assets/images/logo.png',
                        width: 210,
                      ),

                      const SizedBox(height: 4),

                      /// 🔥 TÍTULO
                      const Text(
                        'Criar Conta',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// NOME
                      TextFormField(
                        controller: _nomeController,

                        decoration:
                            _decoracaoCampo(
                          'Nome de usuário',
                        ),

                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      /// EMAIL
                      TextFormField(
                        controller: _emailController,

                        decoration:
                            _decoracaoCampo(
                          'Digite seu e-mail',
                        ),

                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      /// SENHA
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,

                        decoration:
                            _decoracaoCampo(
                          'Senha',
                        ),

                        validator: (v) {
                          if (v == null ||
                              v.length < 6) {
                            return '';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      /// CONFIRMAR SENHA
                      TextFormField(
                        controller:
                            _confirmarSenhaController,

                        obscureText: true,

                        decoration:
                            _decoracaoCampo(
                          'Confirmar senha',
                        ),

                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// TERMOS
                      const Text(
                        'Ao se cadastrar você aceita os termos e privacidade',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// CHECKBOX
                      Row(
                        children: [

                          Checkbox(
                            value: _aceitouTermos,

                            onChanged: (value) {
                              setState(() {
                                _aceitouTermos =
                                    value!;
                              });
                            },

                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                4,
                              ),
                            ),

                            activeColor: Colors.white,
                            checkColor: Colors.black,
                          ),

                          const Expanded(
                            child: Text(
                              'Aceitar termos de privacidade!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// BOTÃO CRIAR
                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                              30,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue
                                    .withOpacity(
                                  0.35,
                                ),

                                blurRadius: 14,

                                offset:
                                    const Offset(
                                  0,
                                  6,
                                ),
                              ),
                            ],

                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(0xFF2D9CFF),
                                Color(0xFF5B6DFF),
                              ],
                            ),
                          ),

                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _cadastrar,

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.transparent,

                              shadowColor:
                                  Colors.transparent,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  30,
                                ),
                              ),
                            ),

                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color:
                                        Colors.white,
                                  )
                                : const Text(
                                    'CRIAR',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.white,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'OU',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// GOOGLE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: OutlinedButton(
                          onPressed: () async {
                                setState(() => _isLoading = true);

                try {
                  final user = await AuthService().signInWithGoogle();

                  if (user != null && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardView(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cadastro cancelado'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }

                setState(() => _isLoading = false);
                          },

                          style:
                              OutlinedButton.styleFrom(
                            backgroundColor:
                                Colors.white,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                30,
                              ),
                            ),

                            side: BorderSide.none,
                          ),

                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [

                              Image.asset(
                                'assets/images/google.png',
                                width: 32,
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              const Text(
                                'Criar com Google',
                                style: TextStyle(
                                  color:
                                      Colors.black,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 17,
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
            ),
          ),
        ],
      ),
    );
  }
}