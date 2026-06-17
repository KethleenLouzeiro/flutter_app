import 'package:flutter/material.dart';

import '../models/map_location.dart';
import 'category_locations_view.dart';

class RestaurantsScreen extends StatelessWidget {
  const RestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryLocationsView(
      title: 'Restaurantes',
      subtitle: 'Encontre restaurantes reais e conhecidos',
      emptyMessage: 'Nenhum restaurante confirmado encontrado para esta busca.',
      icon: Icons.restaurant,
      color: Color(0xFF43B84D),
      categories: [MapLocationCategory.restaurant],
      searchHint: 'Pesquisar restaurante...',
    );
  }
}
