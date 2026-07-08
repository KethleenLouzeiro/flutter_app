import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_app/views/calendario_view.dart';
import 'package:flutter_app/views/configuracao_view.dart';
import 'package:flutter_app/views/hospitais_view.dart';
import 'package:flutter_app/views/hoteis_view.dart';
import 'package:flutter_app/views/mercados_view.dart';
import 'package:flutter_app/views/oficinas_carros_view.dart';
import 'package:flutter_app/views/pets_view.dart';
import 'package:flutter_app/views/pontosturisticos_view.dart';
import 'package:flutter_app/views/postos_view.dart';
import 'package:flutter_app/views/restaurantes_view.dart';
import 'package:flutter_app/views/terminais_hidroviarios_view.dart';
import 'package:flutter_app/views/terminais_rodoviarios_view.dart';

import '../data/para_locations.dart';
import '../models/map_location.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  static const LatLng _paraCenter = LatLng(-3.7000, -52.0000);
  static const String _favoritesKey = 'viagebem_favorite_locations';

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  String nomeUsuario = '';
  String emailUsuario = '';
  String? caminhoFoto;
  Color corPerfil = Colors.deepPurple;

  int _selectedIndex = 0;
  Position? _currentPosition;
  bool _loadingLocation = false;
  String _query = '';
  Set<MapLocationCategory> _activeCategories = {
    for (final option in _categoryOptions) option.category,
  };
  Set<String> _favoriteKeys = {};

  List<MapLocation> get _validLocations {
    return paraLocations
        .where((location) => location.hasValidPosition)
        .toList(growable: false);
  }

  List<MapLocation> get _filteredLocations {
    final normalizedQuery = _normalize(_query);

    return _validLocations.where((location) {
      if (!_activeCategories.contains(location.category)) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      final target = _normalize(
        '${location.name} ${location.city} ${location.description ?? ''}',
      );

      return target.contains(normalizedQuery);
    }).toList(growable: false);
  }

  List<MapLocation> get _favoriteLocations {
    return _validLocations
        .where((location) => _favoriteKeys.contains(_locationKey(location)))
        .toList(growable: false);
  }

  String get _saudacao {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Bom dia';
    }

    if (hour >= 12 && hour < 18) {
      return 'Boa tarde';
    }

    return 'Boa noite';
  }

  String get _displayName {
    if (nomeUsuario.trim().isNotEmpty) {
      return nomeUsuario.trim();
    }

    if (emailUsuario.trim().isNotEmpty) {
      return emailUsuario.trim();
    }

    return 'Viajante';
  }

  @override
  void initState() {
    super.initState();
    _carregarNome();
    _loadFavorites();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarNome() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    setState(() {
      emailUsuario = user?.email ?? '';
      nomeUsuario = prefs.getString('nome_usuario') ?? user?.displayName ?? '';

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

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_favoritesKey) ?? <String>[];

    if (!mounted) return;

    setState(() {
      _favoriteKeys = saved.toSet();
    });
  }

  Future<void> _toggleFavorite(MapLocation location) async {
    final key = _locationKey(location);
    final updated = Set<String>.from(_favoriteKeys);
    final added = updated.add(key);

    if (!added) {
      updated.remove(key);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, updated.toList()..sort());

    if (!mounted) return;

    setState(() {
      _favoriteKeys = updated;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            added
                ? '${location.name} adicionado aos favoritos'
                : '${location.name} removido dos favoritos',
          ),
        ),
      );
  }

  Future<void> _getCurrentLocation() async {
    if (_loadingLocation) return;

    setState(() {
      _loadingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showMessage('Permissao de localizacao negada.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (!position.latitude.isFinite || !position.longitude.isFinite) {
        _showMessage('Localizacao atual invalida.');
        return;
      }

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
      });

      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15,
      );
    } catch (_) {
      _showMessage('Nao foi possivel obter sua localizacao agora.');
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  Future<void> _openRoute(MapLocation location) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination='
      '${location.position.latitude},${location.position.longitude}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    _showMessage('Nao foi possivel abrir a rota.');
  }

  void _focusLocation(MapLocation location) {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
    }

    _mapController.move(location.position, 14);
  }

  void _showLocationDetails(MapLocation location) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final isFavorite = _favoriteKeys.contains(_locationKey(location));

        return _LocationDetailsSheet(
          location: location,
          isFavorite: isFavorite,
          onRoute: () => _openRoute(location),
          onFavorite: () {
            Navigator.pop(context);
            _toggleFavorite(location);
          },
        );
      },
    );
  }

  void _showFilterSheet() {
    var draftCategories = Set<MapLocationCategory>.from(_activeCategories);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtrar pontos no mapa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Escolha quais categorias reais devem aparecer.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: _categoryOptions.map((option) {
                          final count = _countByCategory(option.category);
                          final enabled =
                              draftCategories.contains(option.category);

                          return CheckboxListTile(
                            value: enabled,
                            activeColor: option.color,
                            contentPadding: EdgeInsets.zero,
                            secondary: CircleAvatar(
                              backgroundColor:
                                  option.color.withValues(alpha: 0.14),
                              child: Icon(option.icon, color: option.color),
                            ),
                            title: Text(option.label),
                            subtitle: Text('$count locais confirmados'),
                            onChanged: count == 0
                                ? null
                                : (value) {
                                    setSheetState(() {
                                      if (value == true) {
                                        draftCategories.add(option.category);
                                      } else {
                                        draftCategories.remove(option.category);
                                      }
                                    });
                                  },
                          );
                        }).toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                draftCategories = {
                                  for (final option in _categoryOptions)
                                    if (_countByCategory(option.category) > 0)
                                      option.category,
                                };
                              });
                            },
                            child: const Text('Selecionar tudo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _activeCategories = draftCategories;
                              });

                              Navigator.pop(context);
                            },
                            child: const Text('Aplicar filtros'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _countByCategory(MapLocationCategory category) {
    return _validLocations
        .where((location) => location.category == category)
        .length;
  }

  String _locationKey(MapLocation location) {
    return '${location.category.name}|${location.city}|${location.name}';
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildMapa(),
            _buildFavorites(),
          ],
        ),
      ),
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
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }

  Widget _buildMapa() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
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
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 34,
                    ),
                  ),
              ],
            ),
          ],
        ),
        _buildTopPanel(),
        if (_loadingLocation)
          const Center(
            child: CircularProgressIndicator(),
          ),
        Positioned(
          bottom: 18,
          right: 16,
          child: _MapActionButton(
            icon: Icons.my_location,
            tooltip: 'Minha localizacao',
            onTap: _getCurrentLocation,
          ),
        ),
      ],
    );
  }

  Widget _buildTopPanel() {
    return Positioned(
      top: 12,
      left: 14,
      right: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            elevation: 5,
            shadowColor: Colors.black.withValues(alpha: 0.14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      return InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: corPerfil,
                          backgroundImage: caminhoFoto != null
                              ? FileImage(File(caminhoFoto!))
                              : null,
                          child: caminhoFoto == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_saudacao, $_displayName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_filteredLocations.length} locais no mapa',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _showFilterSheet,
                    tooltip: 'Filtros',
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar lugares no Para...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                        icon: const Icon(Icons.close),
                        tooltip: 'Limpar pesquisa',
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavorites() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Favoritos',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_favoriteLocations.length} locais salvos neste aparelho',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_favoriteLocations.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyFavorites(),
          )
        else
          SliverList.builder(
            itemCount: _favoriteLocations.length,
            itemBuilder: (context, index) {
              final location = _favoriteLocations[index];

              return _FavoriteLocationCard(
                location: location,
                onMapTap: () => _focusLocation(location),
                onDetailsTap: () => _showLocationDetails(location),
                onRemoveTap: () => _toggleFavorite(location),
              );
            },
          ),
      ],
    );
  }

  List<Marker> _buildLocationMarkers() {
    return _filteredLocations.map((location) {
      return Marker(
        point: location.position,
        width: 30,
        height: 34,
        alignment: Alignment.topCenter,
        child: _MapLocationMarker(
          location: location,
          isFavorite: _favoriteKeys.contains(_locationKey(location)),
          onTap: () => _showLocationDetails(location),
        ),
      );
    }).toList(growable: false);
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: corPerfil),
            accountName: Text(_displayName),
            accountEmail: Text(emailUsuario),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  caminhoFoto != null ? FileImage(File(caminhoFoto!)) : null,
              child: caminhoFoto == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
          ),
          _drawerItem(
            Icons.settings,
            'Configuracoes',
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
            'Calendario',
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Divider(thickness: 1),
          ),
          _drawerItem(
            Icons.local_gas_station,
            'Postos',
            const Color.fromARGB(255, 201, 21, 8),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GasStationsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.tour,
            'Pontos Turisticos',
            Colors.orange,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TouristSpotsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.car_repair,
            'Oficinas',
            const Color.fromARGB(255, 28, 25, 34),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OficinasScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.local_grocery_store,
            'Mercados',
            const Color.fromARGB(255, 106, 67, 184),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.restaurant,
            'Restaurantes',
            const Color.fromARGB(255, 67, 184, 77),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RestaurantsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.hotel,
            'Hoteis',
            Colors.purple,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HotelsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.local_hospital,
            'Hospitais',
            Colors.red,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HospitalsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.pets,
            'Pets',
            Colors.teal,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PetsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.directions_boat,
            'Terminais Hidroviarios',
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
            'Terminais Rodoviarios',
            const Color.fromARGB(255, 99, 64, 0),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusTerminalsScreen()),
              );
            },
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
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
    required this.isFavorite,
    required this.onTap,
  });

  final MapLocation location;
  final bool isFavorite;
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
                size: isFavorite ? 34 : 32,
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

class _LocationDetailsSheet extends StatelessWidget {
  const _LocationDetailsSheet({
    required this.location,
    required this.isFavorite,
    required this.onRoute,
    required this.onFavorite,
  });

  final MapLocation location;
  final bool isFavorite;
  final VoidCallback onRoute;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: location.color.withValues(alpha: 0.14),
                  child: Icon(location.icon, color: location.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        location.city,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (location.description != null) ...[
              const SizedBox(height: 16),
              Text(
                location.description!,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRoute,
                    icon: const Icon(Icons.near_me_outlined),
                    label: const Text('Ver rota'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: location.color,
                      side: BorderSide(color: location.color),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    label: Text(isFavorite ? 'Remover' : 'Favoritar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: location.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteLocationCard extends StatelessWidget {
  const _FavoriteLocationCard({
    required this.location,
    required this.onMapTap,
    required this.onDetailsTap,
    required this.onRemoveTap,
  });

  final MapLocation location;
  final VoidCallback onMapTap;
  final VoidCallback onDetailsTap;
  final VoidCallback onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: location.color.withValues(alpha: 0.14),
                    child: Icon(location.icon, color: location.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          location.city,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onRemoveTap,
                    icon: const Icon(Icons.favorite),
                    color: Colors.red,
                    tooltip: 'Remover favorito',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onMapTap,
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('Ver no mapa'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDetailsTap,
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Detalhes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Colors.red,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum local favorito ainda',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Toque em um marcador real no mapa e favorite os locais que deseja acessar depois.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        tooltip: tooltip,
      ),
    );
  }
}

class _DashboardCategory {
  const _DashboardCategory({
    required this.category,
    required this.label,
    required this.icon,
    required this.color,
  });

  final MapLocationCategory category;
  final String label;
  final IconData icon;
  final Color color;
}

const List<_DashboardCategory> _categoryOptions = [
  _DashboardCategory(
    category: MapLocationCategory.gasStation,
    label: 'Postos',
    icon: Icons.local_gas_station,
    color: Color(0xFFC91508),
  ),
  _DashboardCategory(
    category: MapLocationCategory.hospital,
    label: 'Hospitais',
    icon: Icons.local_hospital,
    color: Colors.red,
  ),
  _DashboardCategory(
    category: MapLocationCategory.touristSpot,
    label: 'Pontos turisticos',
    icon: Icons.flag,
    color: Colors.orange,
  ),
  _DashboardCategory(
    category: MapLocationCategory.beach,
    label: 'Praias',
    icon: Icons.beach_access,
    color: Colors.orange,
  ),
  _DashboardCategory(
    category: MapLocationCategory.naturalAttraction,
    label: 'Atracoes naturais',
    icon: Icons.park,
    color: Colors.orange,
  ),
  _DashboardCategory(
    category: MapLocationCategory.historicSite,
    label: 'Locais historicos',
    icon: Icons.account_balance,
    color: Colors.orange,
  ),
  _DashboardCategory(
    category: MapLocationCategory.hotel,
    label: 'Hoteis',
    icon: Icons.hotel,
    color: Colors.purple,
  ),
  _DashboardCategory(
    category: MapLocationCategory.restaurant,
    label: 'Restaurantes',
    icon: Icons.restaurant,
    color: Color.fromARGB(255, 67, 184, 77),
  ),
  _DashboardCategory(
    category: MapLocationCategory.pharmacy,
    label: 'Farmacias',
    icon: Icons.local_pharmacy,
    color: Colors.green,
  ),
  _DashboardCategory(
    category: MapLocationCategory.petShop,
    label: 'Pets',
    icon: Icons.pets,
    color: Colors.teal,
  ),
  _DashboardCategory(
    category: MapLocationCategory.repairShop,
    label: 'Oficinas',
    icon: Icons.car_repair,
    color: Color.fromARGB(255, 28, 25, 34),
  ),
  _DashboardCategory(
    category: MapLocationCategory.market,
    label: 'Mercados',
    icon: Icons.local_grocery_store,
    color: Color.fromARGB(255, 106, 67, 184),
  ),
  _DashboardCategory(
    category: MapLocationCategory.riverPort,
    label: 'Portos fluviais',
    icon: Icons.directions_boat,
    color: Colors.blue,
  ),
  _DashboardCategory(
    category: MapLocationCategory.busTerminal,
    label: 'Terminais rodoviarios',
    icon: Icons.directions_bus,
    color: Color.fromARGB(255, 99, 64, 0),
  ),
];
