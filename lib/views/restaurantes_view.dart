import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class RestaurantsScreen extends StatelessWidget {
  final List<Map<String, String>> restaurants = [
    {
      "name": "Manjar das Garças",
      "address": "Mangal das Garças",
      "distance": "2.0 km",
      "status": "Aberto 11h-22h",
      "rating": "4.7",
      "type": "Culinária Amazônica",
      "history":
          "O Manjar das Garças é um dos restaurantes mais sofisticados de Belém, localizado dentro do parque Mangal das Garças. Oferece pratos típicos da culinária amazônica com apresentação refinada.",
    },
    {
      "name": "Remanso do Peixe",
      "address": "Tv. Quintino Bocaiúva",
      "distance": "1.6 km",
      "status": "Aberto 11h-23h",
      "rating": "4.8",
      "type": "Peixes Regionais",
      "history":
          "Referência em pratos com peixes amazônicos, o Remanso do Peixe é conhecido pela qualidade e sabor autêntico da culinária paraense.",
    },
    {
      "name": "Point do Açaí",
      "address": "Av. Nazaré",
      "distance": "1.2 km",
      "status": "Aberto 09h-21h",
      "rating": "4.5",
      "type": "Regional / Açaí",
      "history":
          "Tradicional ponto para quem quer experimentar o verdadeiro açaí paraense, servido de forma autêntica com acompanhamentos típicos.",
    },
    {
      "name": "Restaurante Lá em Casa",
      "address": "Av. Conselheiro Furtado",
      "distance": "2.8 km",
      "status": "Aberto 11h-22h",
      "rating": "4.6",
      "type": "Comida Paraense",
      "history":
          "Muito conhecido entre turistas, o Lá em Casa oferece pratos tradicionais da culinária paraense como pato no tucupi e maniçoba.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Restaurantes em Belém',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD84315), Color(0xFFFF7043)],
            ),
          ),
        ),
      ),

      body: Column(
        children: [

          /// 🔍 BUSCA
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar restaurante...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          /// HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "🍽️ ${restaurants.length} restaurantes disponíveis",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD84315),
                ),
              ),
            ),
          ),

          /// LISTA
          Expanded(
            child: ListView.builder(
              itemCount: restaurants.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                var restaurant = restaurants[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [

                          /// NOME + RATING
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.restaurant,
                                      color: Colors.deepOrange),
                                  const SizedBox(width: 8),
                                  Text(
                                    restaurant["name"]!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text("${restaurant["rating"]} ⭐"),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// ENDEREÇO
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14),
                              const SizedBox(width: 4),
                              Text(restaurant["address"]!),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// TIPO
                          Row(
                            children: [
                              const Icon(Icons.category, size: 14),
                              const SizedBox(width: 4),
                              Text(restaurant["type"]!),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// STATUS + DISTÂNCIA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(restaurant["status"]!,
                                  style: const TextStyle(color: Colors.green)),
                              Text(restaurant["distance"]!),
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// AÇÕES
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [

                              /// DETALHES
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () =>
                                    _mostrarHistoria(context, restaurant),
                              ),

                              /// COMPARTILHAR
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () => _compartilhar(restaurant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 📖 DETALHES
  void _mostrarHistoria(BuildContext context, Map<String, String> restaurant) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(restaurant["name"]!),
        content: Text(restaurant["history"]!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  /// 📤 COMPARTILHAR
  void _compartilhar(Map<String, String> restaurant) {
    Share.share(
      "Restaurante: ${restaurant["name"]}\nEndereço: ${restaurant["address"]}",
    );
  }
}