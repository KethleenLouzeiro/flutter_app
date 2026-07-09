import 'package:flutter/material.dart';

import '../models/map_location.dart';
import 'category_locations_view.dart';

class RiverTerminalsScreen extends StatelessWidget {
  const RiverTerminalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryLocationsView(
      title: 'Terminais Hidroviarios',
      subtitle: 'Encontre portos e terminais fluviais',
      emptyMessage: 'Nenhum terminal hidroviario confirmado encontrado.',
      icon: Icons.directions_boat,
      color: Color(0xFF0891B2),
      categories: [MapLocationCategory.riverPort],
      searchHint: 'Pesquisar porto ou terminal...',
    );
  }
}
