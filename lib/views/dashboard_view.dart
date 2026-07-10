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
import 'package:flutter_app/services/user_local_keys.dart';
import 'package:flutter_app/views/calendario_view.dart';
import 'package:flutter_app/views/configuracao_view.dart';
import 'package:flutter_app/views/farmacias_view.dart';
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
import 'package:flutter_app/widgets/viagebem_message.dart';

import '../data/para_locations.dart';
import '../models/map_location.dart';

const Color _categoryGasColor = Color(0xFFC91508);
const Color _categoryRestaurantColor = Color(0xFF2E7D32);
const Color _categoryHotelColor = Color(0xFF7B1FA2);
const Color _categoryHospitalColor = Color(0xFFE53935);
const Color _categoryMarketColor = Color(0xFF8B5E00);
const Color _categoryPetColor = Color(0xFF00897B);
const Color _categoryRepairColor = Color(0xFF1C1922);
const Color _categoryTourismColor = Color(0xFFFF8F00);
const Color _categoryPharmacyColor = Color(0xFF1E88E5);
const Color _categoryBusTerminalColor = Color(0xFF2563EB);
const Color _categoryRiverPortColor = Color(0xFF0891B2);

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  static const LatLng _paraCenter = LatLng(-3.7000, -52.0000);
  static const double _bottomNavHeight = 82;
  static const double _bottomNavBottomMargin = -12;
  static const double _overlayGap = 0;
  static const double _routePanelEstimatedHeight = 62;
  static const double _tripPanelEstimatedHeight = 66;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final RouteService _routeService = RouteService();

  String nomeUsuario = '';
  String emailUsuario = '';
  String? caminhoFoto;
  Color corPerfil = Colors.deepPurple;

  int _selectedIndex = 0;
  Position? _currentPosition;
  LatLng? _displayedUserPosition;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _markerAnimationTimer;
  double? _userHeadingRadians;
  bool _trackingHighAccuracy = false;
  bool _loadingLocation = false;
  bool _loadingRoute = false;
  bool _navigationActive = false;
  RouteResult? _activeRoute;
  MapLocation? _routeDestination;
  String _query = '';
  Set<MapLocationCategory> _activeCategories = {};
  Set<String> _favoriteKeys = {};

  List<MapLocation> get _validLocations {
    return paraLocations
        .where((location) => location.hasValidPosition)
        .toList(growable: false);
  }

  List<MapLocation> get _filteredLocations {
    final normalizedQuery = _normalize(_query);

    return _validLocations.where((location) {
      if (!_allCategoriesSelected &&
          !_activeCategories.contains(location.category)) {
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
    return _activeCategories.isEmpty ||
        (_activeCategories.length == _categoryOptions.length &&
            _categoryOptions.every(
              (option) => _activeCategories.contains(option.category),
            ));
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
    _markerAnimationTimer?.cancel();
    _positionSubscription?.cancel();
    _routeService.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarNome() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final savedName =
        uid == null ? null : prefs.getString(UserLocalKeys.nomeUsuario(uid));
    final savedPhoto =
        uid == null ? null : prefs.getString(UserLocalKeys.fotoUsuario(uid));
    final savedColor =
        uid == null ? null : prefs.getInt(UserLocalKeys.corPerfil(uid));

    if (!mounted) return;

    setState(() {
      emailUsuario = user?.email ?? '';
      nomeUsuario = savedName ?? emailUsuario;

      if (nomeUsuario.isEmpty) {
        nomeUsuario = emailUsuario;
      }

      caminhoFoto = savedPhoto;

      corPerfil = savedColor == null ? Colors.deepPurple : Color(savedColor);
    });
  }

  Future<void> _loadFavorites() async {
    final uid = UserLocalKeys.currentUid;

    if (uid == null) {
      if (!mounted) return;

      setState(() {
        _favoriteKeys = {};
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final saved =
        prefs.getStringList(UserLocalKeys.favoritos(uid)) ?? <String>[];

    if (!mounted) return;

    setState(() {
      _favoriteKeys = saved.toSet();
    });
  }

  Future<void> _toggleFavorite(MapLocation location) async {
    final uid = UserLocalKeys.currentUid;

    if (uid == null) {
      _showMessage('Entre novamente para salvar favoritos.');
      return;
    }

    final key = _locationKey(location);
    final updated = Set<String>.from(_favoriteKeys);
    final added = updated.add(key);

    if (!added) {
      updated.remove(key);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      UserLocalKeys.favoritos(uid),
      updated.toList()..sort(),
    );

    if (!mounted) return;

    setState(() {
      _favoriteKeys = updated;
    });

    showViageBemMessage(
      context,
      title: added ? 'Favorito adicionado' : 'Favorito removido',
      subtitle: location.name,
      type: ViageBemMessageType.success,
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

      final previousPosition = _currentPosition;

      setState(() {
        _currentPosition = position;
        _displayedUserPosition = LatLng(position.latitude, position.longitude);
        _userHeadingRadians = _headingFromPosition(position, previousPosition);
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

  Future<void> _startLocationTracking({
    required bool centerOnFirstFix,
    bool highAccuracy = false,
  }) async {
    if (_loadingLocation) return;

    if (_positionSubscription != null) {
      if (_trackingHighAccuracy == highAccuracy) {
        return;
      }

      await _positionSubscription?.cancel();
      _positionSubscription = null;
    }

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
        _displayedUserPosition = LatLng(
          initialPosition.latitude,
          initialPosition.longitude,
        );
        _userHeadingRadians = _headingFromPosition(initialPosition);
      });

      if (centerOnFirstFix) {
        _mapController.move(
          LatLng(initialPosition.latitude, initialPosition.longitude),
          15,
        );
      }

      final locationSettings = LocationSettings(
        accuracy:
            highAccuracy ? LocationAccuracy.best : LocationAccuracy.medium,
        distanceFilter: highAccuracy ? 2 : 10,
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _handlePositionUpdate,
        onError: (_) {
          _showMessage('Nao foi possivel acompanhar sua localizacao agora.');
        },
      );
      _trackingHighAccuracy = highAccuracy;
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

    final previousPosition = _currentPosition;

    setState(() {
      _currentPosition = position;
      _userHeadingRadians = _headingFromPosition(position, previousPosition);
    });

    _animateUserMarkerTo(position);

    if (_navigationActive) {
      _centerMapOnUser();
    }
  }

  void _animateUserMarkerTo(Position position) {
    final target = LatLng(position.latitude, position.longitude);
    final start = _displayedUserPosition;

    _markerAnimationTimer?.cancel();

    if (start == null) {
      setState(() {
        _displayedUserPosition = target;
      });
      return;
    }

    final distanceMeters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      target.latitude,
      target.longitude,
    );

    if (distanceMeters < 1) {
      setState(() {
        _displayedUserPosition = target;
      });
      return;
    }

    const frameCount = 12;
    var frame = 0;

    _markerAnimationTimer = Timer.periodic(
      const Duration(milliseconds: 30),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        frame += 1;
        final progress = frame / frameCount;
        final eased = Curves.easeOutCubic.transform(progress.clamp(0, 1));

        setState(() {
          _displayedUserPosition = LatLng(
            start.latitude + (target.latitude - start.latitude) * eased,
            start.longitude + (target.longitude - start.longitude) * eased,
          );
        });

        if (frame >= frameCount) {
          timer.cancel();
          _markerAnimationTimer = null;
        }
      },
    );
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

  double? _headingFromPosition(Position position, [Position? previous]) {
    if (!position.heading.isFinite || position.heading < 0) {
      if (previous != null) {
        final distance = Geolocator.distanceBetween(
          previous.latitude,
          previous.longitude,
          position.latitude,
          position.longitude,
        );

        if (distance >= 1.5) {
          return _bearingBetween(previous, position);
        }
      }

      return _userHeadingRadians;
    }

    return position.heading * math.pi / 180;
  }

  double _bearingBetween(Position from, Position to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final deltaLongitude = (to.longitude - from.longitude) * math.pi / 180;
    final y = math.sin(deltaLongitude) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLongitude);

    return math.atan2(y, x);
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
      _displayedUserPosition =
          LatLng(routeStart.latitude, routeStart.longitude);
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
        _showMessage(
          'Rota traçada no mapa',
          subtitle: location.name,
          type: ViageBemMessageType.success,
        );
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

    await _startLocationTracking(
      centerOnFirstFix: false,
      highAccuracy: true,
    );

    _centerMapOnUser();
    _showMessage(
      'Viagem iniciada',
      subtitle: location.name,
      type: ViageBemMessageType.success,
    );
  }

  void _clearRoute() {
    final wasNavigating = _navigationActive;

    setState(() {
      _activeRoute = null;
      _routeDestination = null;
      _navigationActive = false;
    });

    if (wasNavigating) {
      _startLocationTracking(
        centerOnFirstFix: false,
        highAccuracy: false,
      );
    }
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

  Future<void> _showFilterMenu(BuildContext anchorContext) async {
    final overlay =
        Overlay.of(anchorContext).context.findRenderObject() as RenderBox;
    final button = anchorContext.findRenderObject() as RenderBox;
    final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final bottomRight = button.localToGlobal(
      button.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );

    final selectedCategories = await showMenu<Set<MapLocationCategory>>(
      context: context,
      color: Colors.transparent,
      elevation: 0,
      position: RelativeRect.fromRect(
        Rect.fromPoints(topLeft, bottomRight),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<Set<MapLocationCategory>>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _FilterPopover(
            options: _filterOptions,
            initiallySelectedCategories:
                _allCategoriesSelected ? const {} : _activeCategories,
            countByCategory: _countByCategory,
            onClear: () {
              Navigator.pop(context, <MapLocationCategory>{});
            },
            onApply: (temporaryCategories) {
              Navigator.pop(
                context,
                temporaryCategories.length == _categoryOptions.length
                    ? <MapLocationCategory>{}
                    : Set<MapLocationCategory>.from(temporaryCategories),
              );
            },
          ),
        ),
      ],
    );

    if (selectedCategories == null || !mounted) return;

    setState(() {
      _activeCategories = selectedCategories;
    });
  }

  int _countByCategory(MapLocationCategory category) {
    return _validLocations
        .where((location) => location.category == category)
        .length;
  }

  Color _routeColorFor(MapLocation location) {
    switch (location.category) {
      case MapLocationCategory.gasStation:
        return _categoryGasColor;
      case MapLocationCategory.restaurant:
        return _categoryRestaurantColor;
      case MapLocationCategory.hotel:
        return _categoryHotelColor;
      case MapLocationCategory.hospital:
        return _categoryHospitalColor;
      case MapLocationCategory.market:
        return _categoryMarketColor;
      case MapLocationCategory.petShop:
        return _categoryPetColor;
      case MapLocationCategory.repairShop:
        return _categoryRepairColor;
      case MapLocationCategory.touristSpot:
      case MapLocationCategory.beach:
      case MapLocationCategory.naturalAttraction:
      case MapLocationCategory.historicSite:
        return _categoryTourismColor;
      case MapLocationCategory.pharmacy:
        return _categoryPharmacyColor;
      case MapLocationCategory.riverPort:
        return _categoryRiverPortColor;
      case MapLocationCategory.busTerminal:
        return _categoryBusTerminalColor;
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

  void _showMessage(
    String message, {
    String? subtitle,
    ViageBemMessageType type = ViageBemMessageType.error,
  }) {
    if (!mounted) return;

    showViageBemMessage(
      context,
      title: message,
      subtitle: subtitle,
      type: type,
    );
  }

  double _panelBottomOffset(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return _bottomNavHeight + _bottomNavBottomMargin + safeBottom + _overlayGap;
  }

  double _locationButtonBottomOffset(BuildContext context) {
    final panelBottom = _panelBottomOffset(context);

    if (_activeRoute == null || _routeDestination == null) {
      return panelBottom;
    }

    final panelHeight = _navigationActive
        ? _tripPanelEstimatedHeight
        : _routePanelEstimatedHeight;

    return panelBottom + panelHeight + _overlayGap;
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
            ConfiguracaoView(
              showBackButton: false,
              onProfileUpdated: _carregarNome,
            ),
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
                if (_displayedUserPosition != null || _currentPosition != null)
                  Marker(
                    point: _displayedUserPosition ??
                        LatLng(
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
          bottom: _locationButtonBottomOffset(context),
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
      bottom: _panelBottomOffset(context),
      child: Material(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 9, 8, 9),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _routeColorFor(destination).withValues(
                  alpha: 0.14,
                ),
                child: Icon(
                  destination.icon,
                  color: _routeColorFor(destination),
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
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
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} km • $durationMinutes min',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _clearRoute,
                tooltip: 'Cancelar rota',
                icon: const Icon(Icons.close),
                visualDensity: VisualDensity.compact,
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
      bottom: _panelBottomOffset(context),
      child: Material(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(20),
        elevation: 14,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: routeColor.withValues(alpha: 0.14),
                child: Icon(destination.icon, color: routeColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Viagem em andamento',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      destination.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TripMetric(
                label: '${distanceKm.toStringAsFixed(1)} km',
                value: '$durationMinutes min',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _endTrip,
                icon: const Icon(Icons.stop_circle_outlined, size: 15),
                label: const Text('Encerrar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: routeColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  minimumSize: const Size(0, 38),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Material(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(30),
              elevation: 12,
              shadowColor: corPerfil.withValues(alpha: 0.38),
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: _searchController,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Pesquisar...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF7371A8),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF373979),
                      size: 25,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 48,
                    ),
                    suffixIcon: _query.isEmpty
                        ? const Icon(
                            Icons.mic_none_rounded,
                            color: Color(0xFF5D5EA8),
                            size: 23,
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
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 48,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Builder(
            builder: (context) {
              return _HeaderIconButton(
                icon: Icons.tune_rounded,
                tooltip: 'Filtros',
                shadowColor: corPerfil,
                showIndicator: !_allCategoriesSelected,
                onTap: () => _showFilterMenu(context),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 82,
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
              child: Builder(
                builder: (context) {
                  return _BottomNavItem(
                    icon: Icons.menu_rounded,
                    label: 'Menu',
                    selected: false,
                    showSideIndicator: true,
                    onTap: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
            ),
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
            Expanded(
              child: _BottomNavItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings_rounded,
                label: 'Configuracoes',
                selected: _selectedIndex == 2,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
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
        width: 38,
        height: 38,
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
      backgroundColor: const Color(0xFFF8FAFF),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _drawerItem(
            Icons.calendar_today,
            'Calendário',
            'Veja seus compromissos',
            const Color(0xFF5B4CF2),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalendarioView(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF7C6DF2),
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'EXPLORAR',
                  style: TextStyle(
                    color: Color(0xFF7C6DF2),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0xFFE5E7F4),
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
            Icons.local_gas_station,
            'Postos',
            'Encontre postos de combustível',
            _categoryGasColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GasStationsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.tour,
            'Pontos Turísticos',
            'Descubra lugares incríveis',
            _categoryTourismColor,
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
            'Oficinas e serviços automotivos',
            _categoryRepairColor,
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
            'Mercados e supermercados',
            _categoryMarketColor,
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
            'Restaurantes e lanchonetes',
            _categoryRestaurantColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RestaurantsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.hotel,
            'Hotéis',
            'Hotéis e pousadas',
            _categoryHotelColor,
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
            'Hospitais e clínicas',
            _categoryHospitalColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HospitalsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.local_pharmacy,
            'Farmácias',
            'Farmácias e drogarias',
            _categoryPharmacyColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PharmaciesScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.pets,
            'Pets',
            'Pet shops e clínicas veterinárias',
            _categoryPetColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PetsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.directions_bus,
            'Terminais Rodoviários',
            'Viagens terrestres',
            _categoryBusTerminalColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusTerminalsScreen()),
              );
            },
          ),
          _drawerItem(
            Icons.directions_boat,
            'Terminais Hidroviários',
            'Viagens pelos rios',
            _categoryRiverPortColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RiverTerminalsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    final hasPhoto = caminhoFoto != null &&
        caminhoFoto!.trim().isNotEmpty &&
        File(caminhoFoto!).existsSync();
    final headerBaseColor = corPerfil;
    final gradientStart = Color.lerp(headerBaseColor, Colors.black, 0.74)!;
    final gradientMiddle = Color.lerp(headerBaseColor, Colors.black, 0.30)!;
    final gradientEnd =
        Color.lerp(headerBaseColor, const Color(0xFF2563EB), 0.34)!;

    return Container(
      height: 230,
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientStart,
            gradientMiddle,
            gradientEnd,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92,
                height: 92,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: headerBaseColor,
                  backgroundImage:
                      hasPhoto ? FileImage(File(caminhoFoto!)) : null,
                  child: hasPhoto
                      ? null
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 54,
                        ),
                ),
              ),
              Positioned(
                right: 3,
                bottom: 5,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  emailUsuario.trim().isEmpty
                      ? 'E-mail não informado'
                      : emailUsuario.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 7,
        shadowColor: const Color(0xFF1E1B4B).withValues(alpha: 0.10),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.24),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 27),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF14182F),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF626984),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: color,
                  size: 30,
                ),
              ],
            ),
          ),
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
          width: 34,
          height: 34,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: isFavorite ? 34 : 30,
                height: isFavorite ? 34 : 30,
                decoration: BoxDecoration(
                  color: location.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.24),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  location.icon,
                  color: Colors.white,
                  size: isFavorite ? 17 : 15,
                ),
              ),
              if (isFavorite)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 10,
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
    return SizedBox(
      width: 52,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 12,
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
    required this.shadowColor,
    this.showIndicator = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color shadowColor;
  final bool showIndicator;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(22),
      elevation: 10,
      shadowColor: shadowColor.withValues(alpha: 0.38),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF373979),
                size: 24,
              ),
              if (showIndicator)
                const Positioned(
                  top: 9,
                  right: 9,
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

class _FilterPopover extends StatefulWidget {
  const _FilterPopover({
    required this.options,
    required this.initiallySelectedCategories,
    required this.countByCategory,
    required this.onClear,
    required this.onApply,
  });

  final List<_DashboardQuickFilter> options;
  final Set<MapLocationCategory> initiallySelectedCategories;
  final int Function(MapLocationCategory category) countByCategory;
  final VoidCallback onClear;
  final ValueChanged<Set<MapLocationCategory>> onApply;

  @override
  State<_FilterPopover> createState() => _FilterPopoverState();
}

class _FilterPopoverState extends State<_FilterPopover> {
  late Set<MapLocationCategory> _temporaryCategories;

  @override
  void initState() {
    super.initState();
    _temporaryCategories = Set<MapLocationCategory>.from(
      widget.initiallySelectedCategories,
    );
  }

  void _toggleOption(_DashboardQuickFilter option, bool selected) {
    setState(() {
      final categories = option.categories;

      if (categories == null) {
        _temporaryCategories = {};
        return;
      }

      if (selected) {
        _temporaryCategories.addAll(categories);
      } else {
        _temporaryCategories.removeAll(categories);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -7,
          right: 24,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.98),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        Material(
          color: Colors.white.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(22),
          elevation: 18,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          child: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Filtrar categorias',
                    style: TextStyle(
                      color: Color(0xFF07112F),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Escolha quais categorias exibir no mapa.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 360,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      primary: false,
                      itemCount: widget.options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 1),
                      itemBuilder: (context, index) {
                        final option = widget.options[index];
                        final selected = _isSelected(option);
                        final count = _countFor(option);

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: count == 0
                              ? null
                              : () => _toggleOption(option, !selected),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 5,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  option.icon,
                                  color: option.color,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    option.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value: selected,
                                  activeColor: const Color(0xFF5A43FF),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: count == 0
                                      ? null
                                      : (value) {
                                          _toggleOption(
                                            option,
                                            value == true,
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: widget.onClear,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Limpar filtros'),
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      foregroundColor: const Color(0xFF4F46E5),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => widget.onApply(_temporaryCategories),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Aplicar filtros'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A43FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _countFor(_DashboardQuickFilter option) {
    final categories = option.categories;

    if (categories == null) {
      return _categoryOptions.fold<int>(
        0,
        (total, option) => total + widget.countByCategory(option.category),
      );
    }

    return categories.fold<int>(
      0,
      (total, category) => total + widget.countByCategory(category),
    );
  }

  bool _isSelected(_DashboardQuickFilter option) {
    final categories = option.categories;

    if (categories == null) {
      return _temporaryCategories.isEmpty;
    }

    return _temporaryCategories.isNotEmpty &&
        categories.every(_temporaryCategories.contains);
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedIcon,
    this.showSideIndicator = false,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showSideIndicator;

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
              size: 27,
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF2118E8)
                          : const Color(0xFF252A5F),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (showSideIndicator) ...[
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF2118E8),
                    size: 16,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 22 : 0,
              height: 3,
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
        width: 54,
        height: 54,
        child: IconButton(
          onPressed: onTap,
          icon: Icon(
            icon,
            color: const Color(0xFF2118E8),
            size: 30,
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

const List<_DashboardQuickFilter> _filterOptions = [
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
    color: _categoryGasColor,
    categories: {MapLocationCategory.gasStation},
  ),
  _DashboardQuickFilter(
    label: 'Restaurantes',
    summaryLabel: 'restaurantes',
    icon: Icons.restaurant,
    color: _categoryRestaurantColor,
    categories: {MapLocationCategory.restaurant},
  ),
  _DashboardQuickFilter(
    label: 'Hospitais',
    summaryLabel: 'hospitais',
    icon: Icons.local_hospital,
    color: _categoryHospitalColor,
    categories: {MapLocationCategory.hospital},
  ),
  _DashboardQuickFilter(
    label: 'Hotéis',
    summaryLabel: 'hotéis',
    icon: Icons.hotel,
    color: _categoryHotelColor,
    categories: {MapLocationCategory.hotel},
  ),
  _DashboardQuickFilter(
    label: 'Mercados',
    summaryLabel: 'mercados',
    icon: Icons.local_grocery_store,
    color: _categoryMarketColor,
    categories: {MapLocationCategory.market},
  ),
  _DashboardQuickFilter(
    label: 'Pets',
    summaryLabel: 'pets',
    icon: Icons.pets,
    color: _categoryPetColor,
    categories: {MapLocationCategory.petShop},
  ),
  _DashboardQuickFilter(
    label: 'Farmacias',
    summaryLabel: 'farmacias',
    icon: Icons.local_pharmacy,
    color: _categoryPharmacyColor,
    categories: {MapLocationCategory.pharmacy},
  ),
  _DashboardQuickFilter(
    label: 'Oficinas',
    summaryLabel: 'oficinas',
    icon: Icons.car_repair,
    color: _categoryRepairColor,
    categories: {MapLocationCategory.repairShop},
  ),
  _DashboardQuickFilter(
    label: 'Pontos Turisticos',
    summaryLabel: 'pontos turísticos',
    icon: Icons.tour,
    color: _categoryTourismColor,
    categories: {
      MapLocationCategory.touristSpot,
      MapLocationCategory.beach,
      MapLocationCategory.naturalAttraction,
      MapLocationCategory.historicSite,
    },
  ),
  _DashboardQuickFilter(
    label: 'Terminais Rodoviarios',
    summaryLabel: 'terminais rodoviarios',
    icon: Icons.directions_bus,
    color: _categoryBusTerminalColor,
    categories: {MapLocationCategory.busTerminal},
  ),
  _DashboardQuickFilter(
    label: 'Terminais Hidroviarios',
    summaryLabel: 'terminais hidroviarios',
    icon: Icons.directions_boat,
    color: _categoryRiverPortColor,
    categories: {MapLocationCategory.riverPort},
  ),
];

const List<_DashboardCategory> _categoryOptions = [
  _DashboardCategory(
    category: MapLocationCategory.gasStation,
    label: 'Postos',
    icon: Icons.local_gas_station,
    color: _categoryGasColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.hospital,
    label: 'Hospitais',
    icon: Icons.local_hospital,
    color: _categoryHospitalColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.touristSpot,
    label: 'Pontos turisticos',
    icon: Icons.flag,
    color: _categoryTourismColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.beach,
    label: 'Praias',
    icon: Icons.beach_access,
    color: _categoryTourismColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.naturalAttraction,
    label: 'Atracoes naturais',
    icon: Icons.park,
    color: _categoryTourismColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.historicSite,
    label: 'Locais historicos',
    icon: Icons.account_balance,
    color: _categoryTourismColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.hotel,
    label: 'Hoteis',
    icon: Icons.hotel,
    color: _categoryHotelColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.restaurant,
    label: 'Restaurantes',
    icon: Icons.restaurant,
    color: _categoryRestaurantColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.pharmacy,
    label: 'Farmacias',
    icon: Icons.local_pharmacy,
    color: _categoryPharmacyColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.petShop,
    label: 'Pets',
    icon: Icons.pets,
    color: _categoryPetColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.repairShop,
    label: 'Oficinas',
    icon: Icons.car_repair,
    color: _categoryRepairColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.market,
    label: 'Mercados',
    icon: Icons.local_grocery_store,
    color: _categoryMarketColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.riverPort,
    label: 'Portos fluviais',
    icon: Icons.directions_boat,
    color: _categoryRiverPortColor,
  ),
  _DashboardCategory(
    category: MapLocationCategory.busTerminal,
    label: 'Terminais rodoviarios',
    icon: Icons.directions_bus,
    color: _categoryBusTerminalColor,
  ),
];
