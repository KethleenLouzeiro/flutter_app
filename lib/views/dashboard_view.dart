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
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => _showComingSoon(context),
          ),
        ],
      ),

      // MENU LATERAL
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 1, 24, 58),
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
                    'Usuário Exemplo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'kethleenks@hotmail.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Política de Privacidade'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
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
                Navigator.pop(context);
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
                Navigator.pop(context);
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
                Navigator.pop(context);
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
      ),

      body: _buildBody(),

      // BARRA INFERIOR
      bottomNavigationBar: NavigationBar(
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
            selectedIcon: Icon(Icons.share),
            label: 'Compartilhar',
          ),
        ],
      ),
    );
  }

  // Controle das telas
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const Center(child: Text('Tela de busca'));
      case 2:
        return const Center(child: Text('Perfil do Usuário'));
      default:
        return _buildDashboard();
    }
  }

  // DASHBOARD
  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, Viajantes! 👋',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Minha agenda de viagens',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            delegate: SliverChildListDelegate([
              _buildCard(Icons.directions, 'Minhas rotas', const Color(0xFF6366F1)),
              _buildCard(Icons.beach_access, 'Lazer', const Color(0xFF8B5CF6)),
              _buildCard(Icons.photo_library, 'Fotos', const Color(0xFFEC4899)),
              _buildCard(Icons.restaurant, 'Restaurantes', const Color(0xFF10B981)),
              _buildCard(Icons.hotel, 'Hoteis', const Color(0xFFF59E0B)),
              _buildCard(Icons.directions_car, 'Transportes', const Color(0xFFEF4444)),
              _buildCard(Icons.tour, 'Pontos turísticos', const Color(0xFFD4D429)),
              _buildCard(Icons.calendar_today, 'Calendario', const Color(0xFF5E15D3)),
              _buildCard(Icons.shopping_bag, 'Compras', const Color(0xFFC92093)),
            ]),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }

  // CARD
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
          color: const Color.fromARGB(255, 217, 217, 238),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
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