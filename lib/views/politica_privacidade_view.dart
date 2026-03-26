import 'package:flutter/material.dart';

class PoliticaPrivacidadeView extends StatelessWidget {
  const PoliticaPrivacidadeView({super.key});

  void _confirmarAceite(BuildContext context) {
    // Exibe um feedback para o usuário
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Termos aceitos com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    // Volta para a Dashboard
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidade')),
      body: Column(
        children: [
          // O Expanded garante que o texto role, mas o botão fique fixo embaixo
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Termos e Condições',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Ao utilizar este aplicativo, você concorda com a coleta de dados para fins de suporte técnico e melhoria da experiência do usuário, conforme as diretrizes da LGPD.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  // Adicione mais blocos de texto se necessário...
                ],
              ),
            ),
          ),
          
          // Área fixa do botão no rodapé
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () => _confirmarAceite(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green, // Cor de confirmação
              ),
              child: const Text(
                'LI E ACEITO OS TERMOS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
