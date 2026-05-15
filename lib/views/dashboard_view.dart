import 'package:flutter/material.dart';
import 'package:flutter_app/views/excluir_view.dart';
import 'package:flutter_app/views/ajuda_suporte_view.dart';
import 'package:flutter_app/views/politica_privacidade_view.dart';
import 'package:flutter_app/views/calendario_view.dart';
import 'package:flutter_app/views/pontosturisticos_view.dart';
import 'package:flutter_app/views/postos_view.dart';
import 'package:flutter_app/views/oficinas_carros_view.dart';
import 'package:flutter_app/views/mercados_view.dart';
import 'package:flutter_app/views/restaurantes_view.dart';
import 'package:flutter_app/views/hoteis_view.dart'; 
import 'package:flutter_app/views/hospitais_view.dart';
import 'package:flutter_app/views/pets_view.dart'; 
import 'package:flutter_app/views/terminalhidroviario_view.dart';

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
              accountName: Text("Patricia"),
              accountEmail: Text("pattystore43@email.com"),
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

            _drawerItem(Icons.local_gas_station, "Postos", const Color.fromARGB(255, 201, 21, 8), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GasStationsScreen(),
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

            _drawerItem(Icons.car_repair, "Oficinas", const Color.fromARGB(255, 28, 25, 34), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OficinasScreen(),
                ),
              );
            }),

            _drawerItem(Icons.local_grocery_store, "Mercado", const Color.fromARGB(255, 106, 67, 184), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MarketsScreen(),
                ),
              );
            }),
             
              _drawerItem(Icons.restaurant, "Restaurantes", const Color.fromARGB(255, 67, 184, 77), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RestaurantsScreen(),
                ),
              );
            }),
            _drawerItem(Icons.hotel, "Hotéis", Colors.purple, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HotelsScreen(),
                ),
            );
          }),
           
           _drawerItem(Icons.local_hospital, "Hospitais", Colors.red, () {
                  Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HospitalsScreen(),
              ),
            );
          }),
          _drawerItem(Icons.pets, "Pets", Colors.teal, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PetsScreen(),
              ),
            );
          }),

          _drawerItem(Icons.directions_boat, "Terminal Hidroviário", Colors.blue, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TerminalHidroviarioScreen(),
              ),
            );
          }),

          

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
  // 🔹 MAPA (layout fake)
Widget _buildMapa() {
  return Stack(
    children: [

      // FUNDO
      Container(
        color: const Color(0xFFEAEAEA),
      ),

      // LINHAS DE FUNDO
      CustomPaint(
        size: Size.infinite,
        painter: GridPainter(),
      ),

      // TOPO
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          child: Row(
            children: [

              // PESQUISA
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 5,
                      )
                    ],
                  ),
                  child: Row(
                    children: const [

                      SizedBox(width: 12),

                      Icon(Icons.menu, color: Colors.black54),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          "Pesquise por um local",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      Icon(Icons.mic, color: Colors.blue),

                      SizedBox(width: 12),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // PERFIL
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 5,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),

      // PIN CENTRAL
      const Center(
        child: Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 50,
        ),
      ),

      // BOTÃO LOCALIZAÇÃO
      Positioned(
        bottom: 90,
        right: 15,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
              )
            ],
          ),
          child: const Icon(
            Icons.my_location,
            color: Colors.black,
          ),
        ),
      ),

      // BARRA INFERIOR
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 60,
          color: Colors.blue,
        ),
      ),
    ],
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

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    const spacing = 60.0;

    // Linhas verticais
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Linhas horizontais
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
