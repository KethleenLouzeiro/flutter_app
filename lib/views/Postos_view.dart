import 'package:flutter/material.dart';

import '../models/map_location.dart';
import 'category_locations_view.dart';

class GasStationsScreen extends StatelessWidget {
  const GasStationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryLocationsView(
      title: 'Postos',
      subtitle: 'Encontre postos de combustivel confirmados',
      emptyMessage:
          'Ainda nao ha postos reais confirmados nesta base. Eles serao adicionados somente com fonte confiavel.',
      icon: Icons.local_gas_station,
      color: Color(0xFFC91508),
      categories: [MapLocationCategory.gasStation],
      searchHint: 'Pesquisar posto...',
    );
  }
}
