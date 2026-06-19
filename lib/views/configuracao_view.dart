import 'package:flutter/material.dart';
import 'package:flutter_app/views/notificacoes_view.dart';
import 'package:flutter_app/views/ajuda_suporte_view.dart';
import 'package:flutter_app/views/politica_privacidade_view.dart';
import 'package:flutter_app/views/editar_perfil_view.dart';

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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditarPerfilView(),
                        ),
                      );
                    },
                  ),
                  _buildItem(
                    icon: Icons.delete_outline,
                    title: 'Excluir Conta',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tela em desenvolvimento',
                          ),
                        ),
                      );
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
                    // Logout futuro
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
}
