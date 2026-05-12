import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class HotelsScreen extends StatelessWidget {
  final List<Map<String, String>> hotels = [
    {
      "name": "Hotel Princesa Louçã",
      "address": "Av. Presidente Vargas",
      "distance": "1.0 km",
      "status": "Recepção 24h",
      "rating": "4.6",
      "type": "Hotel Luxo",
      "history":
          "O Hotel Princesa Louçã é um dos mais tradicionais de Belém, oferecendo conforto, piscina, restaurante e excelente localização no centro da cidade.",
    },
    {
      "name": "Radisson Hotel Belém",
      "address": "Av. Comandante Brás de Aguiar",
      "distance": "1.8 km",
      "status": "Recepção 24h",
      "rating": "4.7",
      "type": "Hotel Premium",
      "history":
          "O Radisson é conhecido pelo alto padrão de qualidade, com quartos modernos, academia, restaurante sofisticado e ótima experiência para hóspedes.",
    },
    {
      "name": "Hotel Sagres",
      "address": "Av. Governador José Malcher",
      "distance": "2.3 km",
      "status": "Recepção 24h",
      "rating": "4.5",
      "type": "Hotel Executivo",
      "history":
          "O Hotel Sagres oferece estrutura completa com piscina, restaurante e espaços para eventos, sendo muito utilizado por viajantes a negócios.",
    },
    {
      "name": "Ibis Styles Belém",
      "address": "Av. Nazaré",
      "distance": "1.5 km",
      "status": "Recepção 24h",
      "rating": "4.4",
      "type": "Hotel Econômico",
      "history":
          "O Ibis Styles é uma opção moderna e acessível, com design diferenciado e conforto ideal para estadias rápidas e práticas.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Hotéis em Belém',
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
              colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
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
                hintText: "Buscar hotel...",
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
                "🏨 ${hotels.length} hotéis disponíveis",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ),
          ),

          /// LISTA
          Expanded(
            child: ListView.builder(
              itemCount: hotels.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                var hotel = hotels[index];

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
                                  const Icon(Icons.hotel,
                                      color: Colors.purple),
                                  const SizedBox(width: 8),
                                  Text(
                                    hotel["name"]!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text("${hotel["rating"]} ⭐"),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// ENDEREÇO
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14),
                              const SizedBox(width: 4),
                              Text(hotel["address"]!),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// TIPO
                          Row(
                            children: [
                              const Icon(Icons.category, size: 14),
                              const SizedBox(width: 4),
                              Text(hotel["type"]!),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// STATUS + DISTÂNCIA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(hotel["status"]!,
                                  style: const TextStyle(color: Colors.green)),
                              Text(hotel["distance"]!),
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
                                    _mostrarDetalhes(context, hotel),
                              ),

                              /// COMPARTILHAR
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () => _compartilhar(hotel),
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
  void _mostrarDetalhes(BuildContext context, Map<String, String> hotel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(hotel["name"]!),
        content: Text(hotel["history"]!),
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
  void _compartilhar(Map<String, String> hotel) {
    Share.share(
      "Hotel: ${hotel["name"]}\nEndereço: ${hotel["address"]}",
    );
  }
}