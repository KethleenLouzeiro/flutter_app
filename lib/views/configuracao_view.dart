import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/views/notificacoes_view.dart';
import 'package:flutter_app/views/ajuda_suporte_view.dart';
import 'package:flutter_app/views/politica_privacidade_view.dart';
import 'package:flutter_app/views/editar_perfil_view.dart';
import 'package:flutter_app/views/splash_view.dart';
import 'package:flutter_app/views/tutorial_view.dart';

class ConfiguracaoView extends StatelessWidget {
  const ConfiguracaoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Configurações',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Preferências do Sistema',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildItem(
                    icon: Icons.notifications_none,
                    title: 'Notificações',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificacoesView(),
                        ),
                      );
                    },
                  ),
                  _buildItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Modo Escuro',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Função em desenvolvimento',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildItem(
                    icon: Icons.help_outline,
                    title: 'Ajuda e Suporte',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AjudaSuporteView(),
                        ),
                      );
                    },
                  ),
                  _buildItem(
                    icon: Icons.play_circle_outline,
                    title: 'Ver tutorial novamente',
                    onTap: () {
                      ViageBemTutorial.show(context);
                    },
                  ),
                  _buildItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Política de Privacidade',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PoliticaPrivacidadeView(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 40,
                    thickness: 1,
                  ),
                  const Text(
                    'Conta',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildItem(
                    icon: Icons.person_outline,
                    title: 'Editar Perfil',
                    onTap: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditarPerfilView(),
                        ),
                      );

                      if (!context.mounted) return;

                      if (resultado == true) {
                        Navigator.pop(context, true);
                      }
                    },
                  ),
                  _buildItem(
                    icon: Icons.delete_outline,
                    title: 'Excluir Conta',
                    onTap: () {
                      _confirmarExcluirConta(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 25,
                top: 10,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    _confirmarSairDaConta(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFA726),
                          Color(0xFF1E88E5),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'SAIR DA CONTA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: Colors.black,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
      ),
      onTap: onTap,
    );
  }

  Future<void> _confirmarSairDaConta(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sair da conta?'),
          content: const Text(
            'Tem certeza que deseja sair da sua conta?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;
    if (!context.mounted) return;

    await _sairDaConta(context);
  }

  Future<void> _sairDaConta(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await _desconectarGoogle();

      if (!context.mounted) return;

      _irParaInicio(context);
    } catch (_) {
      if (!context.mounted) return;

      _mostrarMensagem(
        context,
        'Nao foi possivel sair da conta agora.',
      );
    }
  }

  Future<void> _confirmarExcluirConta(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir conta?'),
          content: const Text(
            'Essa ação é permanente. Tem certeza que deseja excluir sua conta?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;
    if (!context.mounted) return;

    await _excluirConta(context);
  }

  Future<void> _excluirConta(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;

      if (user == null) {
        await _desconectarGoogle();
        await _limparDadosLocaisDoUsuario();

        if (!context.mounted) return;

        _irParaInicio(context);
        return;
      }

      await user.delete();
      await _limparDadosLocaisDoUsuario(uid: uid);
      await _desconectarGoogle();
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      _irParaInicio(context);
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;

      if (error.code == 'requires-recent-login') {
        _mostrarMensagem(
          context,
          'Por segurança, faça login novamente antes de excluir sua conta.',
        );
        return;
      }

      _mostrarMensagem(
        context,
        'Nao foi possivel excluir sua conta agora.',
      );
    } catch (_) {
      if (!context.mounted) return;

      _mostrarMensagem(
        context,
        'Nao foi possivel excluir sua conta agora.',
      );
    }
  }

  Future<void> _desconectarGoogle() async {
    final googleSignIn = GoogleSignIn();

    try {
      await googleSignIn.disconnect();
    } catch (_) {
      // Algumas plataformas retornam erro quando nao ha conta conectada.
    }

    try {
      await googleSignIn.signOut();
    } catch (_) {
      // O logout do Firebase ainda sera executado pelo fluxo principal.
    }
  }

  Future<void> _limparDadosLocaisDoUsuario({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final keysToRemove = <String>{
      'nome_usuario',
      'foto_usuario',
      'cor_perfil',
      'viagebem_favorite_locations',
      ViageBemTutorial.preferenceKey,
    };

    for (final key in prefs.getKeys()) {
      final normalized = key.toLowerCase();
      final belongsToUid = uid != null && key.contains(uid);
      final isUserData = normalized.contains('usuario') ||
          normalized.contains('user') ||
          normalized.contains('perfil') ||
          normalized.contains('profile') ||
          normalized.contains('foto') ||
          normalized.contains('photo') ||
          normalized.contains('favorit') ||
          normalized.contains('favorite') ||
          normalized.contains('sessao') ||
          normalized.contains('session') ||
          normalized.contains('login') ||
          normalized.contains('auth') ||
          normalized.contains('tutorial');

      if (belongsToUid || isUserData) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  void _irParaInicio(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const SplashView(),
      ),
      (_) => false,
    );
  }

  void _mostrarMensagem(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(mensagem),
        ),
      );
  }
}
