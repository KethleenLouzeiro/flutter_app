
import 'package:flutter/material.dart';
import 'package:flutter_app/views/redefinir_senha_view.dart';

class ConfiguracaoView extends StatefulWidget {
  const ConfiguracaoView({super.key});

  @override
  State<ConfiguracaoView> createState() => _ConfiguracaoViewState();
}

class _ConfiguracaoViewState extends State<ConfiguracaoView> {
  bool _notificacoes = true;
  bool _modoEscuro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Preferências do Sistema",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notificações'),
            subtitle: const Text('Receber alertas do sistema'),
            value: _notificacoes,
            onChanged: (bool value) {
              setState(() {
                _notificacoes = value;
              });
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Modo Escuro'),
            value: _modoEscuro,
            onChanged: (bool value) {
              setState(() {
                _modoEscuro = value;
              });
            },
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Conta",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Editar Perfil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ExpansionTile(
            title: const Text("Esqueci minha senha"),
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RedefinirSenhaView(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Esqueceu sua senha? Toque aqui para redefinir agora.",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

          //ListTile(
            //leading: const Icon(Icons.lock_outline),
            //title: const Text('Alterar Senha'),
            //trailing: const Icon(Icons.chevron_right),
            //onTap: () { /* Navegar para alteração de senha */ },
          //),
        //],
      //),
    //);
  
