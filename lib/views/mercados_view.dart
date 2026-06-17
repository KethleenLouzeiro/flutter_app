import 'package:flutter/material.dart';

import '../models/map_location.dart';
import 'category_locations_view.dart';

class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryLocationsView(
      title: 'Mercados',
      subtitle: 'Encontre mercados e feiras confirmadas',
      emptyMessage: 'Nenhum mercado confirmado encontrado para esta busca.',
      icon: Icons.shopping_cart,
      color: Color(0xFF6A43B8),
      categories: [MapLocationCategory.market],
      searchHint: 'Pesquisar mercado...',
    );
  }
}
