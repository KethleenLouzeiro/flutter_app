import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:flutter_app/models/map_point.dart';
import 'package:flutter_app/services/map_service.dart';
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

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() =>
      _DashboardViewState();
}

class _DashboardViewState
    extends State<DashboardView> {

  int _selectedIndex = 0;
  final List<MapPoint> _mapPoints =
      const MapService().getInitialParaPoints();

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  final Map<MapPointCategory, Uint8List> _markerImages = {};

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    await _prepareMarkerImages();
    await _addMapPoints();
  }

  Future<void> _prepareMarkerImages() async {
    if (_markerImages.isNotEmpty) return;

    for (final category in MapPointCategory.values) {
      _markerImages[category] = await _createMarkerImage(
        color: _mapPointColor(category),
        icon: _mapPointIcon(category),
      );
    }
  }

  Future<void> _addMapPoints() async {
    final manager = _pointAnnotationManager;
    if (manager == null) return;

    await manager.deleteAll();

    for (final point in _mapPoints) {
      await manager.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              point.longitude,
              point.latitude,
            ),
          ),
          image: _markerImages[point.category],
          iconAnchor: IconAnchor.CENTER,
          iconSize: 0.72,
        ),
      );
    }
  }

  Future<Uint8List> _createMarkerImage({
    required Color color,
    required IconData icon,
  }) async {
    const size = 96.0;
    const center = Offset(size / 2, size / 2);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(
      center.translate(0, 5),
      31,
      shadowPaint,
    );

    final markerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 30, markerPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, 30, borderPaint);

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      center - Offset(iconPainter.width / 2, iconPainter.height / 2),
    );

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
  }

  Future<void> _focusPara() async {
    await _mapboxMap?.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(
            -52.0,
            -3.7,
          ),
        ),
        zoom: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("VIAGEBEM"),
      ),

      /// ✅ DRAWER
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

  /// 🔹 CORPO
  Widget _buildBody() {

    switch (_selectedIndex) {

      case 0:
        return _buildMapa();

      case 1:
        return const Center(
          child: Text("Busca"),
        );

      default:
        return const Center(
          child: Text("Outro"),
        );
    }
  }

  /// 🔥 MAPA REAL MAPBOX
  Widget _buildMapa() {

    return Stack(
      children: [

        /// 🔥 MAPA
        MapWidget(
          key: const ValueKey(
            "mapWidget",
          ),

          // ignore: deprecated_member_use
          cameraOptions:
              CameraOptions(

            center: Point(
              coordinates:
                  Position(
                -52.0,
                -3.7,
              ),
            ),

            zoom: 5,
          ),

          styleUri:
              MapboxStyles.LIGHT,

          onMapCreated: _onMapCreated,
        ),

        /// 🔥 TOPO
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),

            child: Row(
              children: [

                /// 🔥 PESQUISA
                Expanded(
                  child: Container(
                    height: 45,

                    decoration:
                        BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius
                              .circular(
                        25,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(
                            0.15,
                          ),

                          blurRadius: 5,
                        ),
                      ],
                    ),

                    child: Row(
                      children: const [

                        SizedBox(width: 12),

                        Icon(
                          Icons.menu,
                          color:
                              Colors.black54,
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            "Pesquise por um local",

                            style: TextStyle(
                              color:
                                  Colors.grey,

                              fontSize: 14,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.mic,
                          color: Colors.blue,
                        ),

                        SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// 🔥 PERFIL
                Container(
                  width: 45,
                  height: 45,

                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    shape:
                        BoxShape.circle,

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(
                          0.15,
                        ),

                        blurRadius: 5,
                      ),
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

        /// 🔥 PIN CENTRAL
        const Center(
          child: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 50,
          ),
        ),

        /// 🔥 BOTÃO GPS
        Positioned(
          bottom: 90,
          right: 15,

          child: GestureDetector(
            onTap: _focusPara,
            child: Container(
              width: 50,
              height: 50,

              decoration: BoxDecoration(
                color: Colors.white,

                shape: BoxShape.circle,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(
                      0.2,
                    ),

                    blurRadius: 5,
                  ),
                ],
              ),

              child: const Icon(
                Icons.my_location,
                color: Colors.black,
              ),
            ),
          ),
        ),

        /// 🔥 BARRA INFERIOR
        Align(
          alignment:
              Alignment.bottomCenter,

          child: Container(
            height: 60,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  /// 🔹 DRAWER ITEM
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
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),

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

  void _comingSoon() {

    Navigator.pop(context);

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text("Em breve 🚀"),
      ),
    );
  }
}

/// 🔥 CONFIGURAÇÕES
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

Color _mapPointColor(MapPointCategory category) {
  switch (category) {
    case MapPointCategory.hotel:
      return const Color(0xFFC65AD7);
    case MapPointCategory.mercado:
      return const Color(0xFF6A1B9A);
    case MapPointCategory.posto:
      return const Color(0xFF4F75D9);
    case MapPointCategory.oficina:
      return const Color(0xFFF4B23E);
    case MapPointCategory.restaurante:
      return const Color(0xFF46B946);
    case MapPointCategory.turismo:
      return const Color(0xFFFF7A1A);
    case MapPointCategory.hospital:
      return const Color(0xFFE53935);
    case MapPointCategory.farmacia:
      return const Color(0xFF20BBAA);
    case MapPointCategory.pets:
      return const Color(0xFF8D5A52);
  }
}

IconData _mapPointIcon(MapPointCategory category) {
  switch (category) {
    case MapPointCategory.hotel:
      return Icons.hotel;
    case MapPointCategory.mercado:
      return Icons.shopping_cart;
    case MapPointCategory.posto:
      return Icons.local_gas_station;
    case MapPointCategory.oficina:
      return Icons.directions_car;
    case MapPointCategory.restaurante:
      return Icons.restaurant;
    case MapPointCategory.turismo:
      return Icons.location_on;
    case MapPointCategory.hospital:
      return Icons.local_hospital;
    case MapPointCategory.farmacia:
      return Icons.medical_services;
    case MapPointCategory.pets:
      return Icons.pets;
  }
}
