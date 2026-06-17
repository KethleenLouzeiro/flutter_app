import 'package:flutter/material.dart';

import '../models/map_location.dart';
import 'category_locations_view.dart';

class HotelsScreen extends StatelessWidget {
  const HotelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryLocationsView(
      title: 'Hoteis',
      subtitle: 'Encontre hospedagens reais confirmadas',
      emptyMessage: 'Nenhum hotel confirmado encontrado para esta busca.',
      icon: Icons.hotel,
      color: Color(0xFF9C27B0),
      categories: [MapLocationCategory.hotel],
      searchHint: 'Pesquisar hotel...',
    );
  }
}
