import 'package:flutter/material.dart';
import 'package:flutter_app/views/excluir_view.dart';
import 'package:flutter_app/views/ajuda_suporte_view.dart';
import 'package:flutter_app/views/politica_privacidade_view.dart';
import 'package:flutter_app/views/calendario_view.dart';
import 'package:flutter_app/views/pontosturisticos_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VIAGEBEM"),
      ),

      // ✅ DRAWER CORRETO
      drawer: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Usuário"),
              accountEmail: Text("usuario@email.com"),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
            ),

            _drawerItem(Icons.calendar_today, "Calendário", Colors.blue, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalendarioView(),
                ),
              );
            }),

            _drawerItem(Icons.tour, "Pontos Turísticos", Colors.orange, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TouristSpotsScreen(),
                ),
              );
            }),

            _drawerItem(Icons.restaurant, "Restaurantes", Colors.green, _comingSoon),
            _drawerItem(Icons.hotel, "Hotéis", Colors.purple, _comingSoon),
            _drawerItem(Icons.local_hospital, "Hospitais", Colors.red, _comingSoon),
            _drawerItem(Icons.pets, "Pets", Colors.teal, _comingSoon),

            const Divider(),

            _drawerItem(Icons.settings, "Configurações", Colors.grey, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConfiguracaoView(),
                ),
              );
            }),
          ],
        ),
      ),

      body: _buildBody(),

      // ✅ NAVBAR RESTAURADA
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
        ],
      ),
    );
  }

  // 🔹 CORPO DAS TELAS
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildMapa();
      case 1:
        return const Center(child: Text("Busca"));
      default:
        return const Center(child: Text("Outro"));
    }
  }

  // 🔹 MAPA (placeholder)
  Widget _buildMapa() {
    return const Center(
      child: Text(
        "Mapa aqui 🗺️",
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  // 🔹 ITEM ESTILIZADO DO DRAWER
  Widget _drawerItem(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pop(context); // fecha drawer
            onTap();
          },
        ),
      ),
    );
  }

  void _comingSoon() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Em breve 🚀")),
    );
  }
}

// 🔹 CONFIGURAÇÕES
class ConfiguracaoView extends StatelessWidget {
  const ConfiguracaoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Política de Privacidade'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PoliticaPrivacidadeView(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ajuda e Suporte'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AjudaSuporteView(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              "Excluir Conta",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExcluirView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}