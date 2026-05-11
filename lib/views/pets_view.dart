import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PetsScreen extends StatelessWidget {
  final List<Map<String, String>> pets = [
    {
      "name": "Clínica Veterinária São Francisco",
      "address": "Av. Almirante Barroso",
      "distance": "2.3 km",
      "status": "Atendimento 24h",
      "rating": "4.6",
      "type": "Clínica Veterinária",
      "history":
          "A Clínica São Francisco oferece atendimento completo para cães e gatos, incluindo consultas, cirurgias e emergências.",
    },
    {
      "name": "Hospital Veterinário Belém",
      "address": "Av. Augusto Montenegro",
      "distance": "4.5 km",
      "status": "Atendimento 24h",
      "rating": "4.7",
      "type": "Hospital Veterinário",
      "history":
          "Referência em atendimento veterinário na região, com estrutura moderna e profissionais especializados em diversas áreas.",
    },
    {
      "name": "Pet Shop & Clínica Amigo Animal",
      "address": "Tv. Padre Eutíquio",
      "distance": "1.9 km",
      "status": "Aberto 08h-20h",
      "rating": "4.5",
      "type": "Pet Shop / Clínica",
      "history":
          "Espaço completo com serviços veterinários, banho, tosa e venda de produtos para pets.",
    },
    {
      "name": "Praça Pet Umarizal",
      "address": "Bairro Umarizal",
      "distance": "1.5 km",
      "status": "Aberto 24h",
      "rating": "4.4",
      "type": "Área Pet",
      "history":
          "Espaço ao ar livre dedicado para passeios com animais, com área cercada e ambiente seguro para pets brincarem.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Pets em Belém',
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
              colors: [Color(0xFF00897B), Color(0xFF26A69A)],
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
                hintText: "Buscar serviços pet...",
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
                "🐾 ${pets.length} locais pet disponíveis",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00897B),
                ),
              ),
            ),
          ),

          /// LISTA
          Expanded(
            child: ListView.builder(
              itemCount: pets.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                var pet = pets[index];

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
                                  const Icon(Icons.pets,
                                      color: Colors.teal),
                                  const SizedBox(width: 8),
                                  Text(
                                    pet["name"]!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text("${pet["rating"]} ⭐"),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// ENDEREÇO
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14),
                              const SizedBox(width: 4),
                              Text(pet["address"]!),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// TIPO
                          Row(
                            children: [
                              const Icon(Icons.category, size: 14),
                              const SizedBox(width: 4),
                              Text(pet["type"]!),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// STATUS + DISTÂNCIA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(pet["status"]!,
                                  style: const TextStyle(color: Colors.green)),
                              Text(pet["distance"]!),
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
                                    _mostrarDetalhes(context, pet),
                              ),

                              /// COMPARTILHAR
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () => _compartilhar(pet),
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
  void _mostrarDetalhes(BuildContext context, Map<String, String> pet) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(pet["name"]!),
        content: Text(pet["history"]!),
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
  void _compartilhar(Map<String, String> pet) {
    Share.share(
      "Local Pet: ${pet["name"]}\nEndereço: ${pet["address"]}",
    );
  }
}