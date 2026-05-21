import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
import '../data/para_locations.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() =>
      _DashboardViewState();
}

class _DashboardViewState
    extends State<DashboardView> {

  int _selectedIndex = 0;

  final MapController _mapController =
      MapController();

  void _focusPara() {

    _mapController.move(
      LatLng(
        -3.7,
        -52.0,
      ),
      5,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("VIAGEBEM"),
      ),

      drawer: Drawer(
        child: ListView(
          children: [

            const UserAccountsDrawerHeader(
              accountName:
                  Text("Patricia"),

              accountEmail: Text(
                "pattystore43@email.com",
              ),

              currentAccountPicture:
                  CircleAvatar(
                child: Icon(
                  Icons.person,
                  size: 40,
                ),
              ),
            ),

            _drawerItem(
              Icons.calendar_today,
              "Calendário",
              Colors.blue,
              () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const CalendarioView(),
                  ),
                );
              },
            ),

            _drawerItem(
              Icons.local_gas_station,
              "Postos",

              const Color.fromARGB(
                255,
                201,
                21,
                8,
              ),

              () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GasStationsScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              Icons.tour,
              "Pontos Turísticos",
              Colors.orange,
              () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TouristSpotsScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              Icons.car_repair,
              "Oficinas",

              const Color.fromARGB(
                255,
                28,
                25,
                34,
              ),

              () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OficinasScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              Icons.local_grocery_store,
              "Mercado",

              const Color.fromARGB(
                255,
                106,
                67,
                184,
              ),

              () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MarketsScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              Icons.restaurant,
              "Restaurantes",

              const Color.fromARGB(
                255,
                67,
                184,
                77,
              ),

              () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RestaurantsScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              Icons.hotel,
              "Hotéis",
              Colors.purple,
              () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        HotelsScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              Icons.local_hospital,
              "Hospitais",
              Colors.red,
              () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        HospitalsScreen(),
                  ),
                );
              },
            ),

            _drawerItem(
              Icons.pets,
              "Pets",
              Colors.teal,
              () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PetsScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            _drawerItem(
              Icons.settings,
              "Configurações",
              Colors.grey,
              () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ConfiguracaoView(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {

    switch (_selectedIndex) {

      case 0:
        return _buildMapa();

      default:
        return const Center(
          child: Text("Outro"),
        );
    }
  }

  Widget _buildMapa() {

    return Stack(
      children: [

        FlutterMap(

          mapController: _mapController,

          options: MapOptions(

            initialCenter: LatLng(
              -3.7,
              -52.0,
            ),

            initialZoom: 13,
          ),

          children: [

            TileLayer(

              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

              userAgentPackageName:
                  'com.example.flutter_app',
            ),

MarkerLayer(

  markers:
      paraLocations.map((location) {

    return Marker(

      point: location.position,

      width: 55,
      height: 55,

      child: Column(

        mainAxisSize:
            MainAxisSize.min,

        children: [

          Container(

            padding:
                const EdgeInsets.all(5),

            decoration:
                BoxDecoration(

              color: location.color,

              shape: BoxShape.circle,
            ),

            child: Icon(
              location.icon,

              color: Colors.white,
              size: 18,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            location.name,

            overflow:
                TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 6,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }).toList(),
)
          ],
        ),

        /// 🔥 TOPO
        // SafeArea(
          // child: Padding(
          //   padding:
          //       const EdgeInsets.symmetric(
          //     horizontal: 10,
          //     vertical: 8,
          //   ),

          //   child: Row(
          //     children: [

          //       Expanded(
          //         child: Container(
          //           height: 45,

          //           decoration:
          //               BoxDecoration(
          //             color: const Color.fromARGB(255, 167, 48, 48),

          //             borderRadius:
          //                 BorderRadius
          //                     .circular(
          //               25,
          //             ),

          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black
          //                     .withOpacity(
          //                   0.15,
          //                 ),
          //                 blurRadius: 5,
          //               ),
          //             ],
          //           ),

          //           child: const Row(
          //             children: [

          //               SizedBox(width: 12),

          //               Icon(
          //                 Icons.menu,
          //                 color:
          //                     Color.fromARGB(137, 131, 29, 29),
          //               ),

          //               SizedBox(width: 10),

          //               Expanded(
          //                 child: Text(
          //                   "Pesquise por um local",

          //                   style: TextStyle(
          //                     color:
          //                         Colors.grey,
          //                     fontSize: 14,
          //                   ),
          //                 ),
          //               ),

          //               Icon(
          //                 Icons.mic,
          //                 color: Colors.blue,
          //               ),

          //               SizedBox(width: 12),
          //             ],
          //           ),
          //         ),
          //       ),

          //       const SizedBox(width: 10),

          //       Container(
          //         width: 45,
          //         height: 45,

          //         decoration:
          //             BoxDecoration(
          //           color: Colors.white,
          //           shape:
          //               BoxShape.circle,

          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.black
          //                   .withOpacity(
          //                 0.15,
          //               ),
          //               blurRadius: 5,
          //             ),
          //           ],
          //         ),

          //         child: const Icon(
          //           Icons.person,
          //           color: Colors.blue,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        // ),

        Positioned(
          bottom: 90,
          right: 15,

          child: GestureDetector(
            onTap: _focusPara,

            child: Container(
              width: 50,
              height: 50,

              decoration:
                  const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.my_location,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Marker _buildMarker(
    LatLng point,
    IconData icon,
    Color color,
    String text,
  ) {

    return Marker(

      point: point,

      width: 55,
      height: 55,

      child: Column(

        mainAxisSize: MainAxisSize.min,
        children: [

          Container(

            padding:
                const EdgeInsets.all(5),

            decoration:
                BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            text,

            style: const TextStyle(
              fontSize: 7,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      child: Material(
        color:
            color.withOpacity(0.15),

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        child: ListTile(

          leading: CircleAvatar(
            backgroundColor: color,

            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),

          title: Text(
            title,

            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          trailing: const Icon(
            Icons.chevron_right,
          ),

          onTap: () {

            Navigator.pop(context);

            onTap();
          },
        ),
      ),
    );
  }
}

class ConfiguracaoView
    extends StatelessWidget {

  const ConfiguracaoView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text('Configurações'),
      ),

      body: ListView(
        children: [

          ListTile(
            leading: const Icon(
              Icons.privacy_tip,
            ),

            title: const Text(
              'Política de Privacidade',
            ),

            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PoliticaPrivacidadeView(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.help_outline,
            ),

            title: const Text(
              'Ajuda e Suporte',
            ),

            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AjudaSuporteView(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),

            title: const Text(
              "Excluir Conta",

              style: TextStyle(
                color: Colors.red,
              ),
            ),

            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ExcluirView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}