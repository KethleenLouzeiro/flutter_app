import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/views/calendario_view.dart';
import 'package:flutter_app/views/pontosturisticos_view.dart';
import 'package:flutter_app/views/postos_view.dart';
import 'package:flutter_app/views/oficinas_carros_view.dart';
import 'package:flutter_app/views/mercados_view.dart';
import 'package:flutter_app/views/restaurantes_view.dart';
import 'package:flutter_app/views/hoteis_view.dart';
import 'package:flutter_app/views/hospitais_view.dart';
import 'package:flutter_app/views/pets_view.dart';
import 'package:flutter_app/views/terminais_hidroviarios_view.dart';
import 'package:flutter_app/views/terminais_rodoviarios_view.dart';
import 'package:flutter_app/views/configuracao_view.dart';

import '../data/para_locations.dart';
import '../models/map_location.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  static const LatLng _paraCenter = LatLng(
    -3.7000,
    -52.0000,
  );

  String nomeUsuario = '';

  String emailUsuario = '';

  String? caminhoFoto;

  Color corPerfil = Colors.deepPurple;

  final int _selectedIndex = 0;

  final MapController _mapController = MapController();

  Position? _currentPosition;

  bool _loadingLocation = false;

  List<MapLocation> get _validLocations {
    return paraLocations
        .where((location) => location.hasValidPosition)
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();

    _carregarNome();
    _getCurrentLocation();
  }

  Future<void> _carregarNome() async {
    final prefs = await SharedPreferences.getInstance();

    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      emailUsuario = user?.email ?? '';

      nomeUsuario = prefs.getString('nome_usuario') ?? '';

      if (nomeUsuario.isEmpty) {
        nomeUsuario = emailUsuario;
      }

      caminhoFoto = prefs.getString('foto_usuario');

      final corSalva = prefs.getInt('cor_perfil');

      if (corSalva != null) {
        corPerfil = Color(corSalva);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();

      setState(() {
        _loadingLocation = false;
      });

      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        setState(() {
          _loadingLocation = false;
        });

        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();

      setState(() {
        _loadingLocation = false;
      });

      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(
        seconds: 10,
      ),
    );

    setState(() {
      _currentPosition = position;
      _loadingLocation = false;
    });

    _mapController.move(
      LatLng(
        position.latitude,
        position.longitude,
      ),
      15,
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
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: corPerfil,
              ),
              accountName: Text(nomeUsuario),
              accountEmail: Text(emailUsuario),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    caminhoFoto != null ? FileImage(File(caminhoFoto!)) : null,
                child: caminhoFoto == null
                    ? const Icon(
                        Icons.person,
                        size: 40,
                      )
                    : null,
              ),
            ),
            _drawerItem(
              Icons.settings,
              "Configurações",
              Colors.grey,
              () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConfiguracaoView(),
                  ),
                );

                if (resultado == true) {
                  _carregarNome();
                }
              },
            ),
            _drawerItem(
              Icons.calendar_today,
              "Calendário",
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CalendarioView(),
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Divider(
                thickness: 1,
              ),
            ),
            _drawerItem(
              Icons.local_gas_station,
              "Postos",
              const Color.fromARGB(255, 201, 21, 8),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GasStationsScreen(),
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
                    builder: (_) => TouristSpotsScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              Icons.car_repair,
              "Oficinas",
              const Color.fromARGB(255, 28, 25, 34),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OficinasScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              Icons.local_grocery_store,
              "Mercado",
              const Color.fromARGB(255, 106, 67, 184),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MarketsScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              Icons.restaurant,
              "Restaurantes",
              const Color.fromARGB(255, 67, 184, 77),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantsScreen(),
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
                    builder: (_) => HotelsScreen(),
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
                    builder: (_) => HospitalsScreen(),
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
                    builder: (_) => PetsScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              Icons.directions_boat,
              "Terminais Hidroviarios",
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RiverTerminalsScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              Icons.directions_bus,
              "Terminais Rodoviarios",
              const Color.fromARGB(255, 99, 64, 0),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BusTerminalsScreen(),
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
            initialCenter: _paraCenter,
            initialZoom: 6,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_app',
            ),
            MarkerLayer(
              markers: [
                ..._buildLocationMarkers(),
                if (_currentPosition != null)
                  Marker(
                    point: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 35,
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (_loadingLocation)
          const Center(
            child: CircularProgressIndicator(),
          ),
        Positioned(
          bottom: 90,
          right: 15,
          child: GestureDetector(
            onTap: _getCurrentLocation,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
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

  List<Marker> _buildLocationMarkers() {
    return _validLocations.map((location) {
      return Marker(
        point: location.position,
        width: 30,
        height: 34,
        alignment: Alignment.topCenter,
        child: _MapLocationMarker(
          location: location,
          onTap: () => _showLocationName(location),
        ),
      );
    }).toList(growable: false);
  }

  void _showLocationName(MapLocation location) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text('${location.name} - ${location.city}'),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Material(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(
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
              fontWeight: FontWeight.w600,
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

class _MapLocationMarker extends StatelessWidget {
  const _MapLocationMarker({
    required this.location,
    required this.onTap,
  });

  final MapLocation location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${location.name} - ${location.city}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 34,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Icon(
                Icons.location_on,
                color: location.color,
                size: 32,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.24),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              Positioned(
                top: 5,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    location.icon,
                    color: location.color,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
