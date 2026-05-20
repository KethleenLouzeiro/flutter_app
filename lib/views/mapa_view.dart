// // import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMapScreen extends StatelessWidget {
  const OpenStreetMapScreen({super.key});

  @override
  Widget build(BuildContext context) {

    /// PONTOS PRINCIPAIS
    const LatLng belem = LatLng(-1.4558, -48.4902);

    const LatLng rodoviaria = LatLng(-1.4440, -48.4890);

    const LatLng hidroviario = LatLng(-1.4500, -48.5030);

    return Scaffold(

      /// APPBAR IGUAL AO DASHBOARD
      appBar: AppBar(
        title: const Text(
          "Mapa ViageBem",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),

      /// MAPA
      body: FlutterMap(

        options: const MapOptions(
          initialCenter: belem,
          initialZoom: 13,
        ),

        children: [

          /// MAPA BASE
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.viagebem.app',
          ),

          /// MARCADORES
          MarkerLayer(
            markers: [

              /// 📍 CENTRO (BELÉM)
              Marker(
                point: belem,
                width: 80,
                height: 80,
                child: Column(
                  children: const [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                    Text("Belém"),
                  ],
                ),
              ),

              /// 🚌 RODOVIÁRIA
              Marker(
                point: rodoviaria,
                width: 90,
                height: 90,
                child: Column(
                  children: const [
                    Icon(
                      Icons.directions_bus,
                      color: Colors.orange,
                      size: 40,
                    ),
                    Text("Rodoviária"),
                  ],
                ),
              ),

              /// 🚢 HIDROVIÁRIO
              Marker(
                point: hidroviario,
                width: 90,
                height: 90,
                child: Column(
                  children: const [
                    Icon(
                      Icons.directions_boat,
                      color: Colors.teal,
                      size: 40,
                    ),
                    Text("Hidroviário"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// class OpenStreetMapScreen extends StatelessWidget {
//   const OpenStreetMapScreen({super.key});

//   @override
//   Widget build(BuildContext context) {

//     final LatLng belem = LatLng(
//       -1.4558,
//       -48.4902,
//     );

//     return Scaffold(

//       appBar: AppBar(
//         title: const Text(
//           "Mapa OpenStreetMap",
//         ),
//         backgroundColor: Colors.orange,
//       ),

//       body: FlutterMap(

//         options: MapOptions(
//           initialCenter: belem,
//           initialZoom: 13,
//         ),

//         children: [

//           /// MAPA
//           TileLayer(
//             urlTemplate:
//                 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

//             userAgentPackageName:
//                 'com.example.app',
//           ),

//           /// MARCADOR
//           MarkerLayer(
//             markers: [

//               Marker(
//                 point: belem,

//                 width: 80,
//                 height: 80,

//                 child: Column(
//                   children: [

//                     const Icon(
//                       Icons.location_on,
//                       color: Colors.red,
//                       size: 40,
//                     ),

//                     Container(
//                       padding:
//                           const EdgeInsets.all(4),

//                       color: Colors.white,

//                       child: const Text(
//                         "Belém",
//                         style: TextStyle(
//                           fontWeight:
//                               FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }