import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AjudaSuporteView extends StatelessWidget {
  const AjudaSuporteView({super.key});

  Future<void> _abrirEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'eqviagebemoficial@gmail.com',
      queryParameters: {
        'subject': 'Suporte ViageBem',
      },
    );

    try {
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir o aplicativo de e-mail.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'Ajuda e Suporte',
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              'Precisa de auxílio técnico?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Nossa equipe está disponível para ajudar você com dúvidas, problemas ou sugestões relacionadas ao ViageBem.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 24),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                  ),
                ),
                title: const Text(
                  'Contatar Suporte',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'eqviagebemoficial@gmail.com',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () => _abrirEmail(context),
              ),
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 20),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const ListTile(
                contentPadding: EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  'Sobre o ViageBem',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Versão 1.0.0\nAplicativo de turismo e localização do Pará.',
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                '© ViageBem',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}