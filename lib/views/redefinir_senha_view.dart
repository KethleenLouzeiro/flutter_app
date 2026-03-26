import 'package:flutter/material.dart';
class RedefinirSenhaView extends StatefulWidget {
  const RedefinirSenhaView({super.key});

  @override
  State<RedefinirSenhaView> createState() => _RedefinirSenhaViewState();
}

class _RedefinirSenhaViewState extends State<RedefinirSenhaView> {
  // Controles para capturar o que o usuário digita
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _obscureText = true; // Para esconder/mostrar a senha

  void _atualizarSenha() {
    String novaSenha = _novaSenhaController.text;
    String confirmaSenha = _confirmarSenhaController.text;

    // Validação básica
    if (novaSenha.length < 6) {
      _mostrarMensagem('A senha deve ter pelo menos 6 caracteres', Colors.orange);
      return;
    }

    if (novaSenha == confirmaSenha) {
      // Aqui você chamaria sua lógica de Backend/Firebase futuramente
      _mostrarMensagem('Senha alterada com sucesso!', Colors.green);
      Navigator.pop(context); // Volta para a tela anterior
    } else {
      _mostrarMensagem('As senhas não coincidem!', Colors.red);
    }
  }

  void _mostrarMensagem(String texto, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: cor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar Senha')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.security, size: 70, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Crie uma nova senha forte para sua conta.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            
            // Campo Nova Senha
            TextField(
              controller: _novaSenhaController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Nova Senha',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Campo Confirmar Senha
            TextField(
              controller: _confirmarSenhaController,
              obscureText: _obscureText,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _atualizarSenha,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
              ),
              child: const Text('ATUALIZAR SENHA', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}