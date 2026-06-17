import 'package:flutter/material.dart';

class NotificacoesView extends StatefulWidget {
  const NotificacoesView({super.key});

  @override
  State<NotificacoesView> createState() => _NotificacoesViewState();
}

class _NotificacoesViewState extends State<NotificacoesView> {
  bool alertaTransito = true;
  bool alertaClima = true;
  bool alertaPortos = true;
  bool alertaRodoviarias = true;
  bool novosPontosTuristicos = true;
  bool novidadesViageBem = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Preferências de Notificação',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Escolha quais notificações deseja receber do ViageBem.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.traffic),
              title: const Text('Alertas de Trânsito'),
              subtitle: const Text(
                'Interdições, congestionamentos e acidentes.',
              ),
              value: alertaTransito,
              onChanged: (value) {
                setState(() {
                  alertaTransito = value;
                });
              },
            ),
          ),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.cloud),
              title: const Text('Alertas Climáticos'),
              subtitle: const Text(
                'Chuvas fortes, tempestades e condições climáticas.',
              ),
              value: alertaClima,
              onChanged: (value) {
                setState(() {
                  alertaClima = value;
                });
              },
            ),
          ),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.directions_boat),
              title: const Text('Portos Hidroviários'),
              subtitle: const Text(
                'Alterações e avisos dos terminais hidroviários.',
              ),
              value: alertaPortos,
              onChanged: (value) {
                setState(() {
                  alertaPortos = value;
                });
              },
            ),
          ),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.directions_bus),
              title: const Text('Terminais Rodoviários'),
              subtitle: const Text(
                'Mudanças de horários e funcionamento.',
              ),
              value: alertaRodoviarias,
              onChanged: (value) {
                setState(() {
                  alertaRodoviarias = value;
                });
              },
            ),
          ),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.place),
              title: const Text('Novos Pontos Turísticos'),
              subtitle: const Text(
                'Novos locais cadastrados no aplicativo.',
              ),
              value: novosPontosTuristicos,
              onChanged: (value) {
                setState(() {
                  novosPontosTuristicos = value;
                });
              },
            ),
          ),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.campaign),
              title: const Text('Novidades do ViageBem'),
              subtitle: const Text(
                'Atualizações, melhorias e novidades.',
              ),
              value: novidadesViageBem,
              onChanged: (value) {
                setState(() {
                  novidadesViageBem = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'As notificações serão utilizadas para manter você informado sobre eventos importantes durante suas viagens.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}