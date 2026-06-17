import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum MapLocationCategory {
  gasStation,
  hospital,
  touristSpot,
  beach,
  naturalAttraction,
  historicSite,
  hotel,
  restaurant,
  pharmacy,
  petShop,
  repairShop,
  market,
  riverPort,
  busTerminal,
}

class MapLocation {
  final String name;

  final LatLng position;

  final IconData icon;

  final Color color;

  final MapLocationCategory category;

  final String city;

  final String? description;

  const MapLocation({
    required this.name,
    required this.position,
    required this.icon,
    required this.color,
    required this.category,
    required this.city,
    this.description,
  });

  bool get hasValidPosition {
    final latitude = position.latitude;
    final longitude = position.longitude;

    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}
