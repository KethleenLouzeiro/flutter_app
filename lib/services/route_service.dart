import 'dart:convert';
import 'dart:io';

import 'package:latlong2/latlong.dart';

class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
}

class RouteService {
  RouteService({HttpClient? client}) : _client = client ?? HttpClient();

  final HttpClient _client;

  Future<RouteResult> fetchRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}',
      {
        'overview': 'full',
        'geometries': 'geojson',
        'alternatives': 'false',
        'steps': 'false',
      },
    );

    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');

    final response = await request.close().timeout(
          const Duration(seconds: 15),
        );

    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RouteServiceException('Servico de rotas indisponivel.');
    }

    final decoded = jsonDecode(body);

    if (decoded is! Map<String, dynamic> || decoded['code'] != 'Ok') {
      throw RouteServiceException('Nao foi possivel calcular a rota.');
    }

    final routes = decoded['routes'];

    if (routes is! List || routes.isEmpty) {
      throw RouteServiceException('Nenhuma rota encontrada.');
    }

    final route = routes.first;

    if (route is! Map<String, dynamic>) {
      throw RouteServiceException('Resposta de rota invalida.');
    }

    final geometry = route['geometry'];
    final coordinates =
        geometry is Map<String, dynamic> ? geometry['coordinates'] : null;

    if (coordinates is! List || coordinates.length < 2) {
      throw RouteServiceException('Rota sem geometria valida.');
    }

    final points = <LatLng>[];

    for (final coordinate in coordinates) {
      if (coordinate is! List || coordinate.length < 2) {
        continue;
      }

      final longitude = (coordinate[0] as num?)?.toDouble();
      final latitude = (coordinate[1] as num?)?.toDouble();

      if (latitude == null || longitude == null) {
        continue;
      }

      points.add(LatLng(latitude, longitude));
    }

    if (points.length < 2) {
      throw RouteServiceException('Rota sem pontos suficientes.');
    }

    return RouteResult(
      points: points,
      distanceMeters: (route['distance'] as num?)?.toDouble() ?? 0,
      durationSeconds: (route['duration'] as num?)?.toDouble() ?? 0,
    );
  }

  void close() {
    _client.close(force: true);
  }
}

class RouteServiceException implements Exception {
  const RouteServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
