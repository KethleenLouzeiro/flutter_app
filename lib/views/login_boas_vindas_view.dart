import 'package:flutter/material.dart';
import 'cadastro_view.dart';
import 'dashboard_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'recuperar_senha_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  /// 🔥 FOCUS NODES
  final _emailFocus = FocusNode();
  final _senhaFocus = FocusNode();

  bool _isLoading = false;
  bool _manterConectado = false;

  void _login() async {

    if (!_formKey.currentState!.validate()) {

      if (_emailController.text.isEmpty) {
        FocusScope.of(context)
            .requestFocus(_emailFocus);

      } else if (_senhaController.text.isEmpty) {
        FocusScope.of(context)
            .requestFocus(_senhaFocus);
      }

      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    try {

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login realizado: $email',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardView(),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erro ao fazer login',
          ),
        ),
      );

    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔥 DECORAÇÃO DOS CAMPOS
  InputDecoration _decoracaoCampo(String texto) {
    return InputDecoration(
      hintText: texto,

      filled: true,
      fillColor: Colors.white.withOpacity(0.9),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Colors.white,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
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
        color: Color.fromARGB(255, 252, 0, 0),
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
    _senhaController.dispose();

    _emailFocus.dispose();
    _senhaFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: _background(
        child: SafeArea(
          child: Form(
            key: _formKey,

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  _header(),
                  _form(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 FUNDO COM IMAGEM
  Widget _background({
    required Widget child,
  }) {
    return Stack(
      children: [

        /// IMAGEM DE FUNDO
        Positioned.fill(
          child: Image.asset(
            'assets/images/planodesfoque.png',
            fit: BoxFit.cover,
          ),
        ),

        /// OVERLAY ESCURO
        Container(
          color: Colors.black.withOpacity(0.35),
        ),

        child,
      ],
    );
  }

  /// 🔥 HEADER COM LOGO
  Widget _header() {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 50,
        bottom: 20,
      ),

      child: Center(
        child: Column(
          children: [

            /// LOGO
            Image.asset(
              'assets/images/logo.png',
              width: 210,
            ),

            const SizedBox(height: 60),

            const Text(
              'Bem-vindo!',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        bottom:
            MediaQuery.of(context)
                .viewInsets
                .bottom,
      ),

      child: Column(
        children: [

          /// 🔥 EMAIL
          TextFormField(
            controller: _emailController,

            focusNode: _emailFocus,

            autovalidateMode:
                AutovalidateMode
                    .onUserInteraction,

            cursorColor: Colors.red,

            style: const TextStyle(
              color: Colors.black,
            ),

            decoration:
                _decoracaoCampo(
              'Digite seu e-mail',
            ),

            validator: (value) {

              if (value == null ||
                  value.isEmpty) {

                return 'Digite seu email';
              }

              if (!value.contains('@')) {
                return 'Email inválido';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          /// 🔥 SENHA
          TextFormField(
            controller: _senhaController,
            obscureText: true,

            focusNode: _senhaFocus,

            autovalidateMode:
                AutovalidateMode
                    .onUserInteraction,

            cursorColor: Colors.red,

            style: const TextStyle(
              color: Colors.black,
            ),

            decoration:
                _decoracaoCampo(
              'Senha',
            ),

            validator: (value) {

              if (value == null ||
                  value.isEmpty) {

                return 'Digite sua senha';
              }

              return null;
            },
          ),

          const SizedBox(height: 10),

          /// 🔥 CHECKBOX + ESQUECI
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              Row(
                children: [

                  Checkbox(
                    value:
                        _manterConectado,

                    onChanged: (value) {
                      setState(() {
                        _manterConectado =
                            value!;
                      });
                    },

                    side:
                        const BorderSide(
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

                    activeColor:
                        Colors.white,

                    checkColor:
                        Colors.black,
                  ),

                  const Text(
                    'Manter conectado',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              TextButton(
onPressed: () {

  Navigator.push(
    context,

    MaterialPageRoute(
      builder: (_) =>
          const RecuperarSenhaView(),
    ),
  );
},

                child: const Text(
                  'Esqueceu a senha?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 🔥 BOTÃO ENTRAR
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

                  begin:
                      Alignment.centerLeft,

                  end:
                      Alignment.centerRight,
                ),
              ),

              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _login,

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
                        'ENTRAR',
                        style: TextStyle(
                          color:
                              Colors.white,

                          fontWeight:
                              FontWeight.bold,

                          fontSize: 16,

                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'OU',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 15),

          /// 🔥 GOOGLE LOGIN
          SizedBox(
            width: double.infinity,
            height: 55,

            child: OutlinedButton(
              onPressed: () async {

                setState(
                  () => _isLoading = true,
                );

                try {

                  final user =
                      await AuthService()
                          .loginWithGoogle();

                  if (user != null &&
                      mounted) {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            const DashboardView(),
                      ),
                    );

                  } else {

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Login cancelado',
                        ),
                      ),
                    );
                  }

                } on FirebaseAuthException catch (e) {

  if (e.code == 'google-not-found') {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          'Esse login Google não existe',
        ),
      ),
    );

    return;
  }

  ScaffoldMessenger.of(context)
      .showSnackBar(

    SnackBar(
      content: Text(
        'Erro: ${e.message}',
      ),
    ),
  );
}

                setState(
                  () => _isLoading = false,
                );
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
                    MainAxisAlignment
                        .center,

                children: [

                  /// GOOGLE ICON
                  Image.asset(
                    'assets/images/google.png',
                    width: 40,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  const Text(
                    'Entrar com Google',
                    style: TextStyle(
                      color:
                          Colors.black,

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 CADASTRO
          TextButton(
            onPressed: () {

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      const CadastroView(),
                ),
              );
            },

            child: const Text(
              'Não tem uma conta? CADASTRE-SE',
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}