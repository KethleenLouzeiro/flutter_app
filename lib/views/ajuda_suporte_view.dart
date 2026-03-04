import 'package:flutter/material.dart';

class AjudaSuporteView extends StatelessWidget {
  const AjudaSuporteView({super.key});

  // Função para simular o envio do formulário
  void _simularEnvioEmail(BuildContext context) {
    // Exibe um círculo de carregamento antes de confirmar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simula um atraso de rede de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Fecha o carregamento
      
      // Exibe a mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sua solicitação foi enviada com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda e Suporte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Precisa de auxílio técnico?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Nossa equipe de suporte está disponível para ajudar."),
            const SizedBox(height: 20),
            
            // Botão de Contato por E-mail
            Card(
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: const Text("Enviar chamado por E-mail"),
                subtitle: const Text("Resposta em até 24 horas"),
                onTap: () => _simularEnvioEmail(context), // Chama a simulação
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            
            
          ],
        ),
      ),
    );
  }
}
