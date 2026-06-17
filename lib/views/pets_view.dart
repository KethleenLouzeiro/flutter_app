import 'package:flutter/material.dart';

import '../models/map_location.dart';
import 'category_locations_view.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryLocationsView(
      title: 'Pets',
      subtitle: 'Encontre servicos pet confirmados',
      emptyMessage:
          'Ainda nao ha petshops reais confirmados nesta base. Eles serao adicionados somente com fonte confiavel.',
      icon: Icons.pets,
      color: Colors.teal,
      categories: [MapLocationCategory.petShop],
      searchHint: 'Pesquisar petshop...',
    );
  }
}
