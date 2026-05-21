import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapLocation {

  final String name;

  final LatLng position;

  final IconData icon;

  final Color color;

  MapLocation({
    required this.name,
    required this.position,
    required this.icon,
    required this.color,
  });
}