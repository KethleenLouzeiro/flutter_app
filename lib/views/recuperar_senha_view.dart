import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecuperarSenhaView extends StatefulWidget {
  const RecuperarSenhaView({super.key});

  @override
  State<RecuperarSenhaView> createState() =>
      _RecuperarSenhaViewState();
}

class _RecuperarSenhaViewState
    extends State<RecuperarSenhaView> {

  final _formKey = GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  final _emailFocus = FocusNode();

  bool _isLoading = false;

  Future<void> _enviarEmailReset() async {

    if (!_formKey.currentState!.validate()) {

      FocusScope.of(context)
          .requestFocus(_emailFocus);

      return;
    }

    setState(() => _isLoading = true);

    try {

      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Email de recuperação enviado!',
          ),
        ),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      String erro =
          'Erro ao enviar email';

      if (e.code == 'user-not-found') {
        erro =
            'Nenhuma conta encontrada com este email';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(erro),
        ),
      );

    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔥 DECORAÇÃO
  InputDecoration _decoracaoCampo(
      String texto) {

    return InputDecoration(
      hintText: texto,

      filled: true,
      fillColor:
          Colors.white.withOpacity(0.92),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(30),

        borderSide: BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(30),

        borderSide: BorderSide.none,
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(30),

        borderSide: const BorderSide(
          color: Colors.white,
          width: 2,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(30),

        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(30),

        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 2,
        ),
      ),

      errorStyle: const TextStyle(
        color: Color.fromARGB(
            255, 252, 0, 0),

        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
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
            color:
                Colors.black.withOpacity(
              0.35,
            ),
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
                    bottom:
                        MediaQuery.of(context)
                            .viewInsets
                            .bottom,
                  ),

                  child: Column(
                    children: [

                      /// 🔙 VOLTAR
                      Row(
                        children: [

                          Container(
                            decoration:
                                BoxDecoration(
                              color: Colors.black
                                  .withOpacity(
                                0.25,
                              ),

                              shape:
                                  BoxShape.circle,
                            ),

                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(
                                    context);
                              },

                              icon: const Icon(
                                Icons
                                    .arrow_back_ios_new,

                                color:
                                    Colors.white,

                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 10),

                      /// 🔥 LOGO
                      Image.asset(
                        'assets/images/logo.png',
                        width: 210,
                      ),

                      const SizedBox(
                          height: 15),

                      /// 🔥 TEXTO
                      const Text(
                        'Digite seu email para recuperar sua senha',
                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 30),

                      /// 🔥 EMAIL
                      TextFormField(
                        controller:
                            _emailController,

                        focusNode:
                            _emailFocus,

                        autovalidateMode:
                            AutovalidateMode
                                .onUserInteraction,

                        cursorColor:
                            Colors.red,

                        style:
                            const TextStyle(
                          color: Colors.black,
                        ),

                        decoration:
                            _decoracaoCampo(
                          'Digite seu email',
                        ),

                        validator: (v) {

                          if (v == null ||
                              v.isEmpty) {

                            return
                                'Digite seu email';
                          }

                          if (!v.contains(
                              '@')) {

                            return
                                'Email inválido';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                          height: 30),

                      /// 🔥 BOTÃO ENVIAR
                      SizedBox(
                        width:
                            double.infinity,

                        height: 55,

                        child: DecoratedBox(
                          decoration:
                              BoxDecoration(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              30,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .blue
                                    .withOpacity(
                                  0.35,
                                ),

                                blurRadius:
                                    14,

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
                                Color(
                                    0xFF2D9CFF),

                                Color(
                                    0xFF5B6DFF),
                              ],
                            ),
                          ),

                          child:
                              ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : _enviarEmailReset,

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors
                                      .transparent,

                              shadowColor:
                                  Colors
                                      .transparent,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  30,
                                ),
                              ),
                            ),

                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors
                                        .white,
                                  )
                                : const Text(
                                    'ENVIAR',
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .white,

                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      fontSize:
                                          18,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                      /// 🔥 CANCELAR
                      SizedBox(
                        width:
                            double.infinity,

                        height: 55,

                        child: DecoratedBox(
                          decoration:
                              BoxDecoration(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              30,
                            ),

                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(
                                    0xFFFF3D00),

                                Color(
                                    0xFFFF6A00),
                              ],
                            ),
                          ),

                          child:
                              ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                  context);
                            },

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors
                                      .transparent,

                              shadowColor:
                                  Colors
                                      .transparent,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  30,
                                ),
                              ),
                            ),

                            child: const Text(
                              'CANCELAR',
                              style: TextStyle(
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