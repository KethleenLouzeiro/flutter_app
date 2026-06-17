import 'package:flutter/material.dart';

import '../models/map_location.dart';
import 'category_locations_view.dart';

class OficinasScreen extends StatelessWidget {
  const OficinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryLocationsView(
      title: 'Oficinas',
      subtitle: 'Encontre oficinas confirmadas',
      emptyMessage:
          'Ainda nao ha oficinas reais confirmadas nesta base. Elas serao adicionadas somente com fonte confiavel.',
      icon: Icons.car_repair,
      color: Color(0xFF1C1922),
      categories: [MapLocationCategory.repairShop],
      searchHint: 'Pesquisar oficina...',
    );
  }
}
