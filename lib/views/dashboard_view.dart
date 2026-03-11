import 'package:flutter/material.dart';
import 'package:flutter_app/views/excluir_view.dart';
import 'package:flutter_app/views/ajuda_suporte_view.dart';
import 'package:flutter_app/views/configuracao_view.dart';
import 'package:flutter_app/views/politica_privacidade_view.dart';
import 'package:flutter_app/views/calendario_view.dart';

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
      drawer: _buildDrawer(),

      body: _buildBody(),

      // BOTTOM NAVIGATION MODERNA
      bottomNavigationBar: Container(
        
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
            )
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Buscar',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  // DRAWER
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 0, 20, 61),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30),
                ),
                SizedBox(height: 12),
                Text(
                  'Usuário',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'kethleenks@hotmail.com',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                )
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Política de Privacidade'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PoliticaPrivacidadeView(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ajuda e Suporte'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AjudaSuporteView(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configuração'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfiguracaoView(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Excluir Conta'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExcluirView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // CONTROLE DE TELAS
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const Center(child: Text("Tela de busca"));
      case 2:
        return const Center(child: Text("Perfil do usuário"));
      default:
        return _buildDashboard();
    }
  }

  // DASHBOARD MODERNO
  Widget _buildDashboard() {
    return Stack(
      children: [

        Container(color: const Color(0xFFF4F6FB)),

// TOPO AZUL COM MENU
Container(
  height: 200,
  padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(40),
      bottomRight: Radius.circular(40),
    ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [

      // MENU DRAWER
      Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),

      // TÍTULO E SUBTÍTULO
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Viage Bem",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Minha agenda de viagens",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          )
        ],
      ),

      // AVATAR
      const CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: Colors.blue),
      ),
    ],
  ),
),

        // GRID
        Padding(
          padding: const EdgeInsets.only(top: 160),
          child: GridView.count(
            padding: const EdgeInsets.all(20),
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [

              _buildCard(Icons.map, 'Rotas', Color(0xFF6366F1)),
              _buildCard(Icons.beach_access, 'Lazer', Color(0xFF8B5CF6)),
              _buildCard(Icons.photo_library, 'Fotos', Color(0xFFEC4899)),
              _buildCard(Icons.restaurant, 'Restaurantes', Color(0xFF10B981)),
              _buildCard(Icons.hotel, 'Hotéis', Color(0xFFF59E0B)),
              _buildCard(Icons.directions_car, 'Transportes', Color(0xFFEF4444)),
              _buildCard(Icons.place, 'Turismo', Color(0xFFD4D429)),
              _buildCard(Icons.calendar_today, 'Calendario', Color(0xFF5E15D3)),
              _buildCard(Icons.shopping_bag, 'Compras', Color(0xFFC92093)),

            ],
          ),
        ),
      ],
    );
  }

  // CARD MODERNO
  Widget _buildCard(IconData icon, String title, Color color) {
    return GestureDetector(
      onTap: () {
        if (title == 'Calendario') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CalendarioView(),
            ),
          );
        } else {
          _showComingSoon(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 30),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Em breve! 🚀'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}