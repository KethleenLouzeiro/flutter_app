import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/services/route_service.dart';
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
import 'package:flutter_app/views/tutorial_view.dart';

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
  final RouteService _routeService = RouteService();

  String nomeUsuario = '';
  String emailUsuario = '';
  String? caminhoFoto;
  Color corPerfil = Colors.deepPurple;

  int _selectedIndex = 0;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  double? _userHeadingRadians;
  bool _loadingLocation = false;
  bool _loadingRoute = false;
  bool _navigationActive = false;
  RouteResult? _activeRoute;
  MapLocation? _routeDestination;
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

  bool get _allCategoriesSelected {
    return _activeCategories.length == _categoryOptions.length &&
        _categoryOptions.every(
          (option) => _activeCategories.contains(option.category),
        );
  }

  String get _locationSummary {
    final count = _filteredLocations.length;

    if (_query.trim().isNotEmpty) {
      return '$count resultados encontrados';
    }

    if (_allCategoriesSelected) {
      return '$count locais no mapa';
    }

    _DashboardQuickFilter? selectedFilter;

    for (final filter in _quickFilters) {
      if (filter.categories == null) {
        continue;
      }

      if (_sameCategorySet(filter.categories!, _activeCategories)) {
        selectedFilter = filter;
        break;
      }
    }

    if (selectedFilter != null) {
      return '$count ${selectedFilter.summaryLabel} encontrados';
    }

    return '$count locais encontrados';
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
    _startLocationTracking(centerOnFirstFix: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ViageBemTutorial.showIfNeeded(context);
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _routeService.close();
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

    if (_positionSubscription == null) {
      await _startLocationTracking(centerOnFirstFix: true);
      return;
    }

    setState(() {
      _loadingLocation = true;
    });

    try {
      final canUseLocation = await _ensureLocationPermission();

      if (!canUseLocation) {
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
        _userHeadingRadians = _headingFromPosition(position);
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

  Future<void> _startLocationTracking({required bool centerOnFirstFix}) async {
    if (_positionSubscription != null || _loadingLocation) return;

    setState(() {
      _loadingLocation = true;
    });

    try {
      final canUseLocation = await _ensureLocationPermission();

      if (!canUseLocation) {
        return;
      }

      final initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (!initialPosition.latitude.isFinite ||
          !initialPosition.longitude.isFinite) {
        _showMessage('Localizacao atual invalida.');
        return;
      }

      if (!mounted) return;

      setState(() {
        _currentPosition = initialPosition;
        _userHeadingRadians = _headingFromPosition(initialPosition);
      });

      if (centerOnFirstFix) {
        _mapController.move(
          LatLng(initialPosition.latitude, initialPosition.longitude),
          15,
        );
      }

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _handlePositionUpdate,
        onError: (_) {
          _showMessage('Nao foi possivel acompanhar sua localizacao agora.');
        },
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

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showMessage('Permissao de localizacao negada.');
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  void _handlePositionUpdate(Position position) {
    if (!mounted || !_isUsablePosition(position)) return;

    setState(() {
      _currentPosition = position;
      _userHeadingRadians = _headingFromPosition(position);
    });

    if (_navigationActive) {
      _centerMapOnUser();
    }
  }

  bool _isUsablePosition(Position position) {
    if (!position.latitude.isFinite || !position.longitude.isFinite) {
      return false;
    }

    if (position.accuracy.isFinite && position.accuracy > 150) {
      return false;
    }

    final previous = _currentPosition;

    if (previous == null) {
      return true;
    }

    final distance = Geolocator.distanceBetween(
      previous.latitude,
      previous.longitude,
      position.latitude,
      position.longitude,
    );
    final seconds =
        position.timestamp.difference(previous.timestamp).inMilliseconds.abs() /
            1000;

    if (seconds > 0) {
      final metersPerSecond = distance / seconds;

      if (metersPerSecond > 80 &&
          position.accuracy.isFinite &&
          position.accuracy > 30) {
        return false;
      }
    }

    return true;
  }

  double? _headingFromPosition(Position position) {
    if (!position.heading.isFinite || position.heading < 0) {
      return _userHeadingRadians;
    }

    return position.heading * math.pi / 180;
  }

  Future<bool> _traceRoute(
    MapLocation location, {
    bool showSuccessMessage = true,
  }) async {
    if (_loadingRoute) return false;

    final canUseLocation = await _ensureLocationPermission();

    if (!canUseLocation) {
      return false;
    }

    var position = _currentPosition;

    if (position == null) {
      setState(() {
        _loadingRoute = true;
      });

      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (_) {
        if (mounted) {
          setState(() {
            _loadingRoute = false;
          });
        }

        _showMessage('Ative sua localizacao para tracar a rota.');
        return false;
      }
    }

    if (!position.latitude.isFinite || !position.longitude.isFinite) {
      _showMessage('Localizacao atual invalida para tracar rota.');
      return false;
    }

    final routeStart = position;

    setState(() {
      _loadingRoute = true;
      _currentPosition = routeStart;
      _userHeadingRadians = _headingFromPosition(routeStart);
    });

    try {
      final origin = LatLng(routeStart.latitude, routeStart.longitude);
      final route = await _routeService.fetchRoute(
        origin: origin,
        destination: location.position,
      );

      if (!mounted) return false;

      setState(() {
        _activeRoute = route;
        _routeDestination = location;
        _navigationActive = false;
      });

      _fitRoute(route.points);
      if (showSuccessMessage) {
        _showMessage('Rota para ${location.name} tracada no mapa.');
      }
      return true;
    } on RouteServiceException catch (error) {
      _showMessage(error.message);
      return false;
    } catch (_) {
      _showMessage('Nao foi possivel calcular a rota agora.');
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _loadingRoute = false;
        });
      }
    }
  }

  Future<void> _startTrip(MapLocation location) async {
    if (_loadingRoute) return;

    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
    }

    final hasRouteForDestination = _activeRoute != null &&
        _routeDestination != null &&
        _locationKey(_routeDestination!) == _locationKey(location);

    if (!hasRouteForDestination) {
      final traced = await _traceRoute(
        location,
        showSuccessMessage: false,
      );

      if (!traced) return;
    }

    if (!mounted) return;

    setState(() {
      _navigationActive = true;
      _routeDestination = location;
    });

    _centerMapOnUser();
    _showMessage('Viagem para ${location.name} iniciada.');
  }

  void _clearRoute() {
    setState(() {
      _activeRoute = null;
      _routeDestination = null;
      _navigationActive = false;
    });
  }

  void _endTrip() {
    _clearRoute();
  }

  void _centerMapOnUser() {
    final position = _currentPosition;

    if (position == null) return;

    try {
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        math.max(_mapController.camera.zoom, 16),
      );
    } catch (_) {
      // The map controller can be briefly unavailable during route setup.
    }
  }

  void _fitRoute(List<LatLng> points) {
    if (points.length < 2) return;

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.fromLTRB(36, 220, 36, 150),
        maxZoom: 16,
      ),
    );
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
          onRoute: () {
            Navigator.pop(context);
            _traceRoute(location);
          },
          onStartTrip: () {
            Navigator.pop(context);
            _startTrip(location);
          },
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

  bool _sameCategorySet(
    Set<MapLocationCategory> first,
    Set<MapLocationCategory> second,
  ) {
    return first.length == second.length && first.every(second.contains);
  }

  bool _isQuickFilterSelected(_DashboardQuickFilter filter) {
    if (filter.categories == null) {
      return _allCategoriesSelected;
    }

    return _sameCategorySet(filter.categories!, _activeCategories);
  }

  void _applyQuickFilter(_DashboardQuickFilter filter) {
    setState(() {
      if (filter.categories == null) {
        _activeCategories = {
          for (final option in _categoryOptions) option.category,
        };
      } else {
        _activeCategories = Set<MapLocationCategory>.from(filter.categories!);
      }
    });
  }

  Color _routeColorFor(MapLocation location) {
    switch (location.category) {
      case MapLocationCategory.gasStation:
        return const Color(0xFFC91508);
      case MapLocationCategory.restaurant:
        return const Color.fromARGB(255, 67, 184, 77);
      case MapLocationCategory.hotel:
        return Colors.purple;
      case MapLocationCategory.hospital:
        return Colors.redAccent;
      case MapLocationCategory.market:
        return const Color.fromARGB(255, 106, 67, 184);
      case MapLocationCategory.petShop:
        return Colors.teal;
      case MapLocationCategory.repairShop:
        return const Color.fromARGB(255, 28, 25, 34);
      case MapLocationCategory.touristSpot:
      case MapLocationCategory.beach:
      case MapLocationCategory.naturalAttraction:
      case MapLocationCategory.historicSite:
        return Colors.orange;
      case MapLocationCategory.pharmacy:
        return Colors.green;
      case MapLocationCategory.riverPort:
        return Colors.blue;
      case MapLocationCategory.busTerminal:
        return const Color.fromARGB(255, 99, 64, 0);
    }
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
      extendBody: true,
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
      bottomNavigationBar: _buildBottomNavigation(),
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
            if (_activeRoute != null && _routeDestination != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _activeRoute!.points,
                    color: _routeColorFor(_routeDestination!),
                    strokeWidth: 6,
                    borderStrokeWidth: 3,
                    borderColor: Colors.white.withValues(alpha: 0.90),
                  ),
                ],
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
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    child: _UserLocationMarker(
                      headingRadians: _userHeadingRadians,
                    ),
                  ),
              ],
            ),
          ],
        ),
        _buildTopPanel(),
        if (_activeRoute != null && _routeDestination != null)
          _navigationActive ? _buildTripPanel() : _buildRoutePanel(),
        if (_loadingLocation || _loadingRoute)
          const Center(
            child: CircularProgressIndicator(),
          ),
        Positioned(
          bottom: _navigationActive ? 270 : 116,
          right: 18,
          child: _MapActionButton(
            icon: Icons.my_location,
            tooltip: 'Minha localizacao',
            onTap: _getCurrentLocation,
          ),
        ),
      ],
    );
  }

  Widget _buildRoutePanel() {
    final destination = _routeDestination!;
    final route = _activeRoute!;
    final distanceKm = route.distanceMeters / 1000;
    final durationMinutes = (route.durationSeconds / 60).round();

    return Positioned(
      left: 18,
      right: 18,
      bottom: 188,
      child: Material(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _routeColorFor(destination).withValues(
                  alpha: 0.14,
                ),
                child: Icon(
                  destination.icon,
                  color: _routeColorFor(destination),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      destination.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} km • $durationMinutes min',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _clearRoute,
                tooltip: 'Cancelar rota',
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripPanel() {
    final destination = _routeDestination!;
    final route = _activeRoute!;
    final distanceKm = route.distanceMeters / 1000;
    final durationMinutes = (route.durationSeconds / 60).round();
    final routeColor = _routeColorFor(destination);

    return Positioned(
      left: 18,
      right: 18,
      bottom: 104,
      child: Material(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(26),
        elevation: 14,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: routeColor.withValues(alpha: 0.14),
                    child: Icon(destination.icon, color: routeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Viagem em andamento',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          destination.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _TripMetric(
                      label: 'Distancia',
                      value: '${distanceKm.toStringAsFixed(1)} km',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TripMetric(
                      label: 'Tempo',
                      value: '$durationMinutes min',
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _endTrip,
                    icon: const Icon(Icons.stop_circle_outlined, size: 18),
                    label: const Text('Encerrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: routeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

  Widget _buildTopPanel() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) {
                  return _HeaderIconButton(
                    icon: Icons.menu_rounded,
                    tooltip: 'Menu',
                    selected: true,
                    onTap: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
              const SizedBox(width: 12),
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      corPerfil.withValues(alpha: 0.82),
                      corPerfil,
                    ],
                  ),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: corPerfil.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: caminhoFoto != null
                      ? FileImage(File(caminhoFoto!))
                      : null,
                  child: caminhoFoto == null
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 34,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_saudacao, $_displayName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF07112F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF4F46E5),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _locationSummary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4B4F86),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _HeaderIconButton(
                icon: Icons.tune_rounded,
                tooltip: 'Filtros',
                showIndicator: !_allCategoriesSelected,
                onTap: _showFilterSheet,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(34),
            elevation: 12,
            shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar lugares no Pará...',
                hintStyle: const TextStyle(
                  color: Color(0xFF7371A8),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF373979),
                  size: 30,
                ),
                suffixIcon: _query.isEmpty
                    ? const Icon(
                        Icons.mic_none_rounded,
                        color: Color(0xFF5D5EA8),
                        size: 28,
                      )
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
                  horizontal: 18,
                  vertical: 21,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _quickFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final filter = _quickFilters[index];

                return _QuickFilterChip(
                  filter: filter,
                  selected: _isQuickFilterSelected(filter),
                  onTap: () => _applyQuickFilter(filter),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(40, 0, 40, 18),
      child: Container(
        height: 86,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4338CA).withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _BottomNavItem(
                icon: Icons.map_rounded,
                label: 'Mapa',
                selected: _selectedIndex == 0,
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                icon: Icons.favorite_border_rounded,
                selectedIcon: Icons.favorite_rounded,
                label: 'Favoritos',
                selected: _selectedIndex == 1,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ),
          ],
        ),
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

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker({
    required this.headingRadians,
  });

  final double? headingRadians;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Transform.rotate(
            angle: headingRadians ?? 0,
            child: Icon(
              headingRadians == null
                  ? Icons.my_location
                  : Icons.navigation_rounded,
              color: const Color(0xFF2563EB),
              size: headingRadians == null ? 20 : 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _TripMetric extends StatelessWidget {
  const _TripMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationDetailsSheet extends StatelessWidget {
  const _LocationDetailsSheet({
    required this.location,
    required this.isFavorite,
    required this.onRoute,
    required this.onStartTrip,
    required this.onFavorite,
  });

  final MapLocation location;
  final bool isFavorite;
  final VoidCallback onRoute;
  final VoidCallback onStartTrip;
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
            if (location.address != null) ...[
              const SizedBox(height: 14),
              _LocationInfoRow(
                icon: Icons.place_outlined,
                text: location.address!,
              ),
            ],
            if (location.phone != null) ...[
              const SizedBox(height: 8),
              _LocationInfoRow(
                icon: Icons.phone_outlined,
                text: location.phone!,
              ),
            ],
            if (location.openingHours != null) ...[
              const SizedBox(height: 8),
              _LocationInfoRow(
                icon: Icons.schedule,
                text: location.openingHours!,
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRoute,
                    icon: const Icon(Icons.near_me_outlined),
                    label: const Text('Traçar rota'),
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
                    onPressed: onStartTrip,
                    icon: const Icon(Icons.navigation_rounded),
                    label: const Text('Iniciar viagem'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: location.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                label: Text(isFavorite ? 'Remover favorito' : 'Favoritar'),
                style: TextButton.styleFrom(
                  foregroundColor: location.color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationInfoRow extends StatelessWidget {
  const _LocationInfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
      ],
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.selected = false,
    this.showIndicator = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool selected;
  final bool showIndicator;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(22),
      elevation: 10,
      shadowColor: const Color(0xFF4338CA).withValues(alpha: 0.16),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF373979),
                size: 32,
              ),
              if (selected)
                const Positioned(
                  bottom: 9,
                  child: SizedBox(
                    width: 24,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6A00),
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                      ),
                    ),
                  ),
                ),
              if (showIndicator)
                const Positioned(
                  top: 12,
                  right: 12,
                  child: SizedBox(
                    width: 10,
                    height: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6A00),
                        shape: BoxShape.circle,
                      ),
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

class _QuickFilterChip extends StatelessWidget {
  const _QuickFilterChip({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final _DashboardQuickFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        selected ? const Color(0xFF2118E8) : const Color(0xFF07112F);

    return Material(
      color: Colors.white.withValues(alpha: selected ? 0.98 : 0.92),
      borderRadius: BorderRadius.circular(22),
      elevation: selected ? 8 : 4,
      shadowColor:
          const Color(0xFF4338CA).withValues(alpha: selected ? 0.16 : 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7C6CFF)
                  : Colors.white.withValues(alpha: 0.70),
              width: selected ? 1.6 : 1,
            ),
            gradient: selected
                ? LinearGradient(
                    colors: [
                      const Color(0xFF7C6CFF).withValues(alpha: 0.14),
                      Colors.white.withValues(alpha: 0.95),
                    ],
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filter.icon,
                color: selected ? const Color(0xFF2118E8) : filter.color,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                filter.label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF5A43FF).withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? selectedIcon ?? icon : icon,
              color:
                  selected ? const Color(0xFF2118E8) : const Color(0xFF252A5F),
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF2118E8)
                    : const Color(0xFF252A5F),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 28 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2118E8),
                borderRadius: BorderRadius.circular(99),
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
      elevation: 12,
      shadowColor: const Color(0xFF4338CA).withValues(alpha: 0.20),
      child: SizedBox(
        width: 62,
        height: 62,
        child: IconButton(
          onPressed: onTap,
          icon: Icon(
            icon,
            color: const Color(0xFF2118E8),
            size: 34,
          ),
          tooltip: tooltip,
        ),
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

class _DashboardQuickFilter {
  const _DashboardQuickFilter({
    required this.label,
    required this.summaryLabel,
    required this.icon,
    required this.color,
    this.categories,
  });

  final String label;
  final String summaryLabel;
  final IconData icon;
  final Color color;
  final Set<MapLocationCategory>? categories;
}

const List<_DashboardQuickFilter> _quickFilters = [
  _DashboardQuickFilter(
    label: 'Todos',
    summaryLabel: 'locais',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF6C5CFF),
  ),
  _DashboardQuickFilter(
    label: 'Postos',
    summaryLabel: 'postos',
    icon: Icons.local_gas_station,
    color: Color(0xFFFF6A00),
    categories: {MapLocationCategory.gasStation},
  ),
  _DashboardQuickFilter(
    label: 'Restaurantes',
    summaryLabel: 'restaurantes',
    icon: Icons.restaurant,
    color: Color(0xFF1677F2),
    categories: {MapLocationCategory.restaurant},
  ),
  _DashboardQuickFilter(
    label: 'Hospitais',
    summaryLabel: 'hospitais',
    icon: Icons.local_hospital,
    color: Color(0xFFE53935),
    categories: {MapLocationCategory.hospital},
  ),
  _DashboardQuickFilter(
    label: 'Hotéis',
    summaryLabel: 'hotéis',
    icon: Icons.hotel,
    color: Color(0xFF9C27B0),
    categories: {MapLocationCategory.hotel},
  ),
  _DashboardQuickFilter(
    label: 'Mercados',
    summaryLabel: 'mercados',
    icon: Icons.local_grocery_store,
    color: Color(0xFF6A43B8),
    categories: {MapLocationCategory.market},
  ),
  _DashboardQuickFilter(
    label: 'Pets',
    summaryLabel: 'pets',
    icon: Icons.pets,
    color: Colors.teal,
    categories: {MapLocationCategory.petShop},
  ),
  _DashboardQuickFilter(
    label: 'Oficinas',
    summaryLabel: 'oficinas',
    icon: Icons.car_repair,
    color: Color(0xFF1C1922),
    categories: {MapLocationCategory.repairShop},
  ),
  _DashboardQuickFilter(
    label: 'Turismo',
    summaryLabel: 'pontos turísticos',
    icon: Icons.tour,
    color: Colors.orange,
    categories: {
      MapLocationCategory.touristSpot,
      MapLocationCategory.beach,
      MapLocationCategory.naturalAttraction,
      MapLocationCategory.historicSite,
    },
  ),
];

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
