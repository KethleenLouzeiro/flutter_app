import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_location.dart';

final List<MapLocation> paraLocations = [

  /// 🔥 VER-O-PESO
  MapLocation(

    name: 'Ver-o-Peso',

    position: LatLng(
      -1.4513,
      -48.5022,
    ),

    icon: Icons.location_on,

    color: Colors.orange,
  ),

  /// 🔥 ESTAÇÃO DAS DOCAS
  MapLocation(

    name: 'Estação das Docas',

    position: LatLng(
      -1.44861,
      -48.50028,
    ),

    icon: Icons.tour,

    color: Colors.orange,
  ),

  /// 🔥 HOSPITAL PORTO DIAS
  MapLocation(

    name: 'Hospital Porto Dias',

    position: LatLng(
      -1.451611,
      -48.478108,
    ),

    icon: Icons.local_hospital,

    color: Colors.red,
  ),

  /// 🔥 HOTEL SAGRES
  MapLocation(

    name: 'Hotel Sagres',

    position: LatLng(
      -1.44336,
      -48.46978,
    ),

    icon: Icons.hotel,

    color: Colors.purple,
  ),

  /// 🔥 TERMINAL HIDROVIÁRIO
  MapLocation(

    name: 'Terminal Hidroviário de Belém',

    position: LatLng(
      -1.44600,
      -48.49783,
    ),

    icon: Icons.directions_boat,

    color: Colors.blue,
  ),

  /// 🔥 RESTAURANTE
  MapLocation(

    name: 'Point do Açaí',

    position: LatLng(
      -1.454950,
      -48.488950,
    ),

    icon: Icons.restaurant,

    color: Colors.green,
  ),
];