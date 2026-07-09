import 'package:flutter/material.dart';

import '../models/map_location.dart';
import 'category_locations_view.dart';

class PharmaciesScreen extends StatelessWidget {
  const PharmaciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryLocationsView(
      title: 'Farmacias',
      subtitle: 'Encontre farmacias confirmadas no Para',
      emptyMessage: 'Nenhuma farmacia confirmada encontrada para esta busca.',
      icon: Icons.local_pharmacy,
      color: Color(0xFF1E88E5),
      categories: [MapLocationCategory.pharmacy],
      searchHint: 'Pesquisar farmacia...',
    );
  }
}
