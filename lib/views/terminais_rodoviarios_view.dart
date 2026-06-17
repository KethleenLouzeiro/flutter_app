import 'package:flutter/material.dart';

import '../models/map_location.dart';
import 'category_locations_view.dart';

class BusTerminalsScreen extends StatelessWidget {
  const BusTerminalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryLocationsView(
      title: 'Terminais Rodoviarios',
      subtitle: 'Encontre terminais de onibus confirmados',
      emptyMessage: 'Nenhum terminal rodoviario confirmado encontrado.',
      icon: Icons.directions_bus,
      color: Color.fromARGB(255, 99, 64, 0),
      categories: [MapLocationCategory.busTerminal],
      searchHint: 'Pesquisar terminal rodoviario...',
    );
  }
}
