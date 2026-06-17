import 'package:flutter/material.dart';

import '../models/map_location.dart';
import 'category_locations_view.dart';

class HospitalsScreen extends StatelessWidget {
  const HospitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryLocationsView(
      title: 'Hospitais',
      subtitle: 'Encontre hospitais reais no Para',
      emptyMessage: 'Nenhum hospital confirmado encontrado para esta busca.',
      icon: Icons.local_hospital,
      color: Color(0xFFE53935),
      categories: [MapLocationCategory.hospital],
      searchHint: 'Pesquisar hospital...',
    );
  }
}
