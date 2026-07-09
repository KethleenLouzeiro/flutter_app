import 'package:flutter/material.dart';

import '../models/map_location.dart';
import 'category_locations_view.dart';

class TouristSpotsScreen extends StatelessWidget {
  const TouristSpotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryLocationsView(
      title: 'Pontos Turisticos',
      subtitle: 'Explore praias, historia e natureza do Para',
      emptyMessage: 'Nenhum ponto turistico confirmado encontrado.',
      icon: Icons.flag,
      color: Color(0xFFFF8F00),
      categories: [
        MapLocationCategory.touristSpot,
        MapLocationCategory.beach,
        MapLocationCategory.naturalAttraction,
        MapLocationCategory.historicSite,
      ],
      searchHint: 'Pesquisar atracao...',
    );
  }
}
