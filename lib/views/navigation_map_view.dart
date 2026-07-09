import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_location.dart';
import '../services/route_service.dart';
import '../widgets/viagebem_message.dart';

class NavigationMapView extends StatefulWidget {
  const NavigationMapView({
    super.key,
    required this.destination,
    required this.routeColor,
    this.initialRoute,
    this.initialPosition,
  });

  final MapLocation destination;
  final Color routeColor;
  final RouteResult? initialRoute;
  final Position? initialPosition;

  @override
  State<NavigationMapView> createState() => _NavigationMapViewState();
}

class _NavigationMapViewState extends State<NavigationMapView> {
  final MapController _mapController = MapController();
  final RouteService _routeService = RouteService();

  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  RouteResult? _activeRoute;
  bool _loadingRoute = true;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    _activeRoute = widget.initialRoute;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startNavigation();
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _routeService.close();
    super.dispose();
  }

  Future<void> _startNavigation() async {
    setState(() {
      _loadingRoute = true;
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

      RouteResult route;

      if (_activeRoute == null) {
        route = await _routeService.fetchRoute(
          origin: LatLng(position.latitude, position.longitude),
          destination: widget.destination.position,
        );
      } else {
        route = _activeRoute!;
      }

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _activeRoute = route;
      });

      _fitRoute(route.points);
      _listenToPosition();
    } on RouteServiceException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Nao foi possivel iniciar a viagem agora.');
    } finally {
      if (mounted) {
        setState(() {
          _loadingRoute = false;
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

  void _listenToPosition() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2,
      ),
    ).listen(
      (position) {
        if (!mounted ||
            !position.latitude.isFinite ||
            !position.longitude.isFinite) {
          return;
        }

        setState(() {
          _currentPosition = position;
        });

        _centerMapOnUser();
      },
      onError: (_) {
        _showMessage('Nao foi possivel acompanhar sua localizacao agora.');
      },
    );
  }

  void _fitRoute(List<LatLng> points) {
    if (points.length < 2) return;

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.fromLTRB(36, 90, 36, 220),
        maxZoom: 16,
      ),
    );
  }

  void _centerMapOnUser() {
    final position = _currentPosition;

    if (position == null) return;

    try {
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        _mapController.camera.zoom < 16 ? 16 : _mapController.camera.zoom,
      );
    } catch (_) {
      // The map controller can be briefly unavailable during startup.
    }
  }

  void _endTrip() {
    _positionSubscription?.cancel();
    _positionSubscription = null;

    if (!mounted) return;

    setState(() {
      _activeRoute = null;
    });

    showViageBemMessage(
      context,
      title: 'Viagem encerrada',
      subtitle: widget.destination.name,
      type: ViageBemMessageType.info,
    );

    Navigator.pop(context);
  }

  void _showMessage(
    String message, {
    ViageBemMessageType type = ViageBemMessageType.error,
  }) {
    if (!mounted) return;

    showViageBemMessage(
      context,
      title: message,
      type: type,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = _currentPosition;
    final userPoint = currentPosition == null
        ? null
        : LatLng(currentPosition.latitude, currentPosition.longitude);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userPoint ?? widget.destination.position,
              initialZoom: 14,
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
              if (_activeRoute != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _activeRoute!.points,
                      color: widget.routeColor,
                      strokeWidth: 6,
                      borderStrokeWidth: 2,
                      borderColor: Colors.white.withValues(alpha: 0.92),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.destination.position,
                    width: 42,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: _NavigationDestinationMarker(
                      location: widget.destination,
                      color: widget.routeColor,
                    ),
                  ),
                  if (userPoint != null)
                    Marker(
                      point: userPoint,
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      child: const _NavigationUserMarker(),
                    ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.96),
                    shape: const CircleBorder(),
                    elevation: 8,
                    child: IconButton(
                      onPressed: _endTrip,
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Encerrar viagem',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(18),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        child: Text(
                          widget.destination.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loadingRoute)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_activeRoute != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: SafeArea(
                child: _NavigationTripPanel(
                  destination: widget.destination,
                  route: _activeRoute!,
                  color: widget.routeColor,
                  onEndTrip: _endTrip,
                ),
              ),
            ),
          Positioned(
            right: 18,
            bottom: _activeRoute == null ? 32 : 174,
            child: SafeArea(
              child: Material(
                color: Colors.white.withValues(alpha: 0.96),
                shape: const CircleBorder(),
                elevation: 8,
                child: IconButton(
                  onPressed: _centerMapOnUser,
                  icon: Icon(
                    Icons.my_location,
                    color: widget.routeColor,
                  ),
                  tooltip: 'Minha localizacao',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationDestinationMarker extends StatelessWidget {
  const _NavigationDestinationMarker({
    required this.location,
    required this.color,
  });

  final MapLocation location;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Icon(
          Icons.location_on,
          color: color,
          size: 44,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        Positioned(
          top: 7,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(location.icon, color: color, size: 13),
          ),
        ),
      ],
    );
  }
}

class _NavigationUserMarker extends StatelessWidget {
  const _NavigationUserMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location,
            color: Color(0xFF2563EB),
            size: 17,
          ),
        ),
      ],
    );
  }
}

class _NavigationTripPanel extends StatelessWidget {
  const _NavigationTripPanel({
    required this.destination,
    required this.route,
    required this.color,
    required this.onEndTrip,
  });

  final MapLocation destination;
  final RouteResult route;
  final Color color;
  final VoidCallback onEndTrip;

  @override
  Widget build(BuildContext context) {
    final distanceKm = route.distanceMeters / 1000;
    final durationMinutes = (route.durationSeconds / 60).round();

    return Material(
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
                  backgroundColor: color.withValues(alpha: 0.14),
                  child: Icon(destination.icon, color: color),
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
                  onPressed: onEndTrip,
                  icon: const Icon(Icons.stop_circle_outlined, size: 18),
                  label: const Text('Encerrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
