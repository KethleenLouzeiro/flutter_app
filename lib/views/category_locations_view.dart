import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/para_locations.dart';
import '../models/map_location.dart';
import '../services/route_service.dart';
import '../widgets/viagebem_message.dart';
import 'navigation_map_view.dart';

class CategoryLocationsView extends StatefulWidget {
  const CategoryLocationsView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.icon,
    required this.color,
    required this.categories,
    this.searchHint,
  });

  final String title;
  final String subtitle;
  final String emptyMessage;
  final IconData icon;
  final Color color;
  final List<MapLocationCategory> categories;
  final String? searchHint;

  @override
  State<CategoryLocationsView> createState() => _CategoryLocationsViewState();
}

class _CategoryLocationsViewState extends State<CategoryLocationsView> {
  static const LatLng _defaultCenter = LatLng(-1.4558, -48.4902);
  static const String _favoritesKey = 'viagebem_favorite_locations';

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final RouteService _routeService = RouteService();

  String _query = '';
  MapLocation? _selectedLocation;
  Position? _currentPosition;
  Set<String> _favoriteKeys = {};
  bool _loadingRoute = false;
  RouteResult? _activeRoute;
  MapLocation? _routeDestination;

  List<MapLocation> get _categoryLocations {
    return paraLocations
        .where((location) =>
            location.hasValidPosition &&
            widget.categories.contains(location.category))
        .toList(growable: false);
  }

  List<MapLocation> get _filteredLocations {
    final normalizedQuery = _normalize(_query);

    if (normalizedQuery.isEmpty) {
      return _categoryLocations;
    }

    return _categoryLocations.where((location) {
      final target = _normalize(
        '${location.name} ${location.city} ${location.description ?? ''}',
      );
      return target.contains(normalizedQuery);
    }).toList(growable: false);
  }

  LatLng get _initialCenter {
    if (_filteredLocations.isNotEmpty) {
      return _filteredLocations.first.position;
    }

    if (_categoryLocations.isNotEmpty) {
      return _categoryLocations.first.position;
    }

    return _defaultCenter;
  }

  @override
  void dispose() {
    _routeService.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _selectLocation(MapLocation location) {
    setState(() {
      _selectedLocation = location;
    });

    _mapController.move(location.position, 14);
  }

  void _showDetails(MapLocation location) {
    _selectLocation(location);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _LocationDetailsSheet(
          location: location,
          categoryTitle: widget.title,
          color: widget.color,
          icon: widget.icon,
          isFavorite: _favoriteKeys.contains(_locationKey(location)),
          onRoute: () {
            Navigator.pop(context);
            _traceRoute(location);
          },
          onStartTrip: () {
            Navigator.pop(context);
            _startTrip(location);
          },
          onFavorite: () => _toggleFavorite(location),
        );
      },
    );
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_favoritesKey) ?? <String>[];

    if (!mounted) return;

    setState(() {
      _favoriteKeys = saved.toSet();
    });
  }

  Future<bool> _traceRoute(
    MapLocation location, {
    bool showSuccessMessage = true,
  }) async {
    if (_loadingRoute) return false;

    setState(() {
      _loadingRoute = true;
      _selectedLocation = location;
    });

    try {
      final canUseLocation = await _ensureLocationPermission();

      if (!canUseLocation) {
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (!position.latitude.isFinite || !position.longitude.isFinite) {
        _showMessage('Localizacao atual invalida para tracar rota.');
        return false;
      }

      final route = await _routeService.fetchRoute(
        origin: LatLng(position.latitude, position.longitude),
        destination: location.position,
      );

      if (!mounted) return false;

      setState(() {
        _currentPosition = position;
        _activeRoute = route;
        _routeDestination = location;
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
    final hasRouteForDestination = _activeRoute != null &&
        _routeDestination != null &&
        _locationKey(_routeDestination!) == _locationKey(location);

    setState(() {
      _selectedLocation = location;
    });

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => NavigationMapView(
          destination: location,
          routeColor: _routeColorFor(location),
          initialRoute: hasRouteForDestination ? _activeRoute : null,
          initialPosition: _currentPosition,
        ),
      ),
    );
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

  void _fitRoute(List<LatLng> points) {
    if (points.length < 2) return;

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 92),
        maxZoom: 16,
      ),
    );
  }

  void _clearRoute() {
    setState(() {
      _activeRoute = null;
      _routeDestination = null;
    });
  }

  String _locationKey(MapLocation location) {
    return '${location.category.name}|${location.city}|${location.name}';
  }

  Color _routeColorFor(MapLocation location) {
    switch (location.category) {
      case MapLocationCategory.gasStation:
        return const Color(0xFFC91508);
      case MapLocationCategory.restaurant:
        return const Color(0xFF2E7D32);
      case MapLocationCategory.hotel:
        return const Color(0xFF7B1FA2);
      case MapLocationCategory.hospital:
        return const Color(0xFFE53935);
      case MapLocationCategory.market:
        return const Color(0xFF8B5E00);
      case MapLocationCategory.petShop:
        return const Color(0xFF00897B);
      case MapLocationCategory.repairShop:
        return const Color.fromARGB(255, 28, 25, 34);
      case MapLocationCategory.touristSpot:
      case MapLocationCategory.beach:
      case MapLocationCategory.naturalAttraction:
      case MapLocationCategory.historicSite:
        return const Color(0xFFFF8F00);
      case MapLocationCategory.pharmacy:
        return const Color(0xFF1E88E5);
      case MapLocationCategory.riverPort:
        return const Color(0xFF0891B2);
      case MapLocationCategory.busTerminal:
        return const Color(0xFF2563EB);
    }
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

  Future<void> _toggleFavorite(MapLocation location) async {
    Navigator.pop(context);
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

    showViageBemMessage(
      context,
      title: added ? 'Favorito adicionado' : 'Favorito removido',
      subtitle: location.name,
      type: ViageBemMessageType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: Column(
          children: [
            _CategoryHeader(
              title: widget.title,
              subtitle: widget.subtitle,
              icon: widget.icon,
              color: widget.color,
              onBack: () => Navigator.pop(context),
              onFilter: _showFilterInfo,
            ),
            _SearchField(
              controller: _searchController,
              hintText: widget.searchHint ?? 'Pesquisar local...',
              color: widget.color,
              onChanged: (value) {
                setState(() {
                  _query = value;
                  _selectedLocation = null;
                });
              },
              onClear: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                  _selectedLocation = null;
                });
              },
            ),
            _CategoryMap(
              locations: _filteredLocations,
              selectedLocation: _selectedLocation,
              controller: _mapController,
              initialCenter: _initialCenter,
              color: widget.color,
              icon: widget.icon,
              title: widget.title,
              onMarkerTap: _showDetails,
              onFocusTap: () {
                _mapController.move(_initialCenter, 13);
              },
              activeRoute: _activeRoute,
              currentPosition: _currentPosition,
              routeDestination: _routeDestination,
              routeColor: _routeDestination == null
                  ? widget.color
                  : _routeColorFor(_routeDestination!),
              loadingRoute: _loadingRoute,
              onClearRoute: _clearRoute,
            ),
            _ResultSummary(
              count: _filteredLocations.length,
              title: widget.title,
              color: widget.color,
            ),
            Expanded(
              child: _filteredLocations.isEmpty
                  ? _EmptyCategoryState(
                      icon: widget.icon,
                      color: widget.color,
                      message: widget.emptyMessage,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                      itemCount: _filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = _filteredLocations[index];
                        final isSelected = location == _selectedLocation;

                        return _LocationCard(
                          location: location,
                          categoryTitle: widget.title,
                          icon: widget.icon,
                          color: widget.color,
                          isSelected: isSelected,
                          onMapTap: () => _selectLocation(location),
                          onDetailsTap: () => _showDetails(location),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterInfo() {
    showViageBemMessage(
      context,
      title: 'Filtros avançados',
      subtitle: 'Serão conectados aos dados reais.',
      type: ViageBemMessageType.info,
    );
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
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onBack,
    required this.onFilter,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onBack;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Voltar',
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF526071),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onFilter,
            icon: const Icon(Icons.tune),
            tooltip: 'Filtros',
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.color,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final Color color;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                  tooltip: 'Limpar',
                ),
          filled: true,
          fillColor: const Color(0xFFEFF1F4),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: color.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryMap extends StatelessWidget {
  const _CategoryMap({
    required this.locations,
    required this.selectedLocation,
    required this.controller,
    required this.initialCenter,
    required this.color,
    required this.icon,
    required this.title,
    required this.onMarkerTap,
    required this.onFocusTap,
    required this.activeRoute,
    required this.currentPosition,
    required this.routeDestination,
    required this.routeColor,
    required this.loadingRoute,
    required this.onClearRoute,
  });

  final List<MapLocation> locations;
  final MapLocation? selectedLocation;
  final MapController controller;
  final LatLng initialCenter;
  final Color color;
  final IconData icon;
  final String title;
  final ValueChanged<MapLocation> onMarkerTap;
  final VoidCallback onFocusTap;
  final RouteResult? activeRoute;
  final Position? currentPosition;
  final MapLocation? routeDestination;
  final Color routeColor;
  final bool loadingRoute;
  final VoidCallback onClearRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            FlutterMap(
              mapController: controller,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: locations.length <= 1 ? 13 : 6,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutter_app',
                ),
                if (activeRoute != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: activeRoute!.points,
                        color: routeColor,
                        strokeWidth: 5,
                        borderStrokeWidth: 2,
                        borderColor: Colors.white.withValues(alpha: 0.90),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    ...locations.map((location) {
                      final isSelected = location == selectedLocation;
                      return Marker(
                        point: location.position,
                        width: isSelected ? 40 : 32,
                        height: isSelected ? 44 : 36,
                        alignment: Alignment.topCenter,
                        child: _CategoryPin(
                          icon: icon,
                          color: color,
                          selected: isSelected,
                          onTap: () => onMarkerTap(location),
                        ),
                      );
                    }),
                    if (currentPosition != null)
                      Marker(
                        point: LatLng(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                        ),
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: const _CategoryUserMarker(),
                      ),
                  ],
                ),
              ],
            ),
            if (loadingRoute)
              const Center(
                child: CircularProgressIndicator(),
              ),
            Positioned(
              top: 14,
              left: 14,
              child: _MapCounter(
                count: locations.length,
                color: color,
              ),
            ),
            Positioned(
              right: 12,
              top: 14,
              child: _FloatingMapButton(
                icon: Icons.my_location,
                onTap: onFocusTap,
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: activeRoute == null || routeDestination == null
                  ? _CategoryMapBanner(
                      icon: icon,
                      color: color,
                      text: 'Exibindo apenas: $title',
                    )
                  : _CategoryRouteBanner(
                      destination: routeDestination!,
                      route: activeRoute!,
                      color: routeColor,
                      onClearRoute: onClearRoute,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryMapBanner extends StatelessWidget {
  const _CategoryMapBanner({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRouteBanner extends StatelessWidget {
  const _CategoryRouteBanner({
    required this.destination,
    required this.route,
    required this.color,
    required this.onClearRoute,
  });

  final MapLocation destination;
  final RouteResult route;
  final Color color;
  final VoidCallback onClearRoute;

  @override
  Widget build(BuildContext context) {
    final distanceKm = route.distanceMeters / 1000;
    final durationMinutes = (route.durationSeconds / 60).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(destination.icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${distanceKm.toStringAsFixed(1)} km • $durationMinutes min',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClearRoute,
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Cancelar rota',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _CategoryUserMarker extends StatelessWidget {
  const _CategoryUserMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location,
            color: Color(0xFF2563EB),
            size: 16,
          ),
        ),
      ],
    );
  }
}

class _CategoryPin extends StatelessWidget {
  const _CategoryPin({
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: selected ? 1.16 : 1,
        curve: Curves.easeOut,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Icon(
              Icons.location_on,
              color: color,
              size: selected ? 40 : 32,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: selected ? 8 : 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            Positioned(
              top: selected ? 7 : 5,
              child: Container(
                width: selected ? 18 : 15,
                height: selected ? 18 : 15,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: selected ? 12 : 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCounter extends StatelessWidget {
  const _MapCounter({
    required this.count,
    required this.color,
  });

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count locais encontrados',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingMapButton extends StatelessWidget {
  const _FloatingMapButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon),
        ),
      ),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({
    required this.count,
    required this.title,
    required this.color,
  });

  final int count;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 2),
      child: Row(
        children: [
          Text(
            '$count locais encontrados',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.categoryTitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onMapTap,
    required this.onDetailsTap,
  });

  final MapLocation location;
  final String categoryTitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onMapTap;
  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : const Color(0xFFE5E7EB),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.06),
            blurRadius: isSelected ? 16 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 25,
                ),
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
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _InfoLine(
                      icon: Icons.location_on_outlined,
                      text: location.city,
                    ),
                    const SizedBox(height: 4),
                    _InfoLine(
                      icon: Icons.category_outlined,
                      text: categoryTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Confirmado',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'No mapa',
                    style: TextStyle(
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (location.description != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                location.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMapTap,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Ver no mapa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color.withValues(alpha: 0.85)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDetailsTap,
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Detalhes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationDetailsSheet extends StatelessWidget {
  const _LocationDetailsSheet({
    required this.location,
    required this.categoryTitle,
    required this.color,
    required this.icon,
    required this.isFavorite,
    required this.onRoute,
    required this.onStartTrip,
    required this.onFavorite,
  });

  final MapLocation location;
  final String categoryTitle;
  final Color color;
  final IconData icon;
  final bool isFavorite;
  final VoidCallback onRoute;
  final VoidCallback onStartTrip;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.58,
      minChildSize: 0.36,
      maxChildSize: 0.86,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          categoryTitle,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: location.position,
                      initialZoom: 14,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.flutter_app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: location.position,
                            width: 36,
                            height: 40,
                            alignment: Alignment.topCenter,
                            child: _CategoryPin(
                              icon: icon,
                              color: color,
                              selected: true,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _DetailLine(
                icon: Icons.location_on_outlined,
                label: 'Local',
                value: location.address ?? location.city,
              ),
              _DetailLine(
                icon: Icons.verified_outlined,
                label: 'Status',
                value: 'Local real confirmado',
              ),
              _DetailLine(
                icon: Icons.schedule,
                label: 'Horario',
                value: location.openingHours ?? 'Nao informado',
              ),
              _DetailLine(
                icon: Icons.phone_outlined,
                label: 'Telefone',
                value: location.phone ?? 'Nao informado',
              ),
              if (location.description != null)
                _DetailLine(
                  icon: Icons.notes_outlined,
                  label: 'Descricao',
                  value: location.description!,
                ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRoute,
                      icon: const Icon(Icons.near_me_outlined),
                      label: const Text('Traçar rota'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(isFavorite ? 'Remover favorito' : 'Favoritar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF374151)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategoryState extends StatelessWidget {
  const _EmptyCategoryState({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
