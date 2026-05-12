import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class HospitalsScreen extends StatelessWidget {
  final List<Map<String, String>> hospitals = [
    {
      "name": "Hospital Metropolitano",
      "address": "BR-316, Ananindeua",
      "distance": "5.0 km",
      "status": "Atendimento 24h",
      "rating": "4.3",
      "type": "Público",
      "history":
          "O Hospital Metropolitano é referência em atendimento de alta complexidade no Pará, oferecendo serviços gratuitos pelo SUS com estrutura moderna.",
    },
    {
      "name": "Hospital Adventista de Belém",
      "address": "Av. Gov. José Malcher",
      "distance": "2.2 km",
      "status": "Atendimento 24h",
      "rating": "4.6",
      "type": "Particular",
      "history":
          "O Hospital Adventista oferece atendimento de alta qualidade, com foco em humanização, tecnologia e serviços médicos especializados.",
    },
    {
      "name": "Santa Casa de Misericórdia",
      "address": "Av. Generalíssimo Deodoro",
      "distance": "1.8 km",
      "status": "Atendimento 24h",
      "rating": "4.2",
      "type": "Público",
      "history":
          "Fundada há mais de um século, a Santa Casa é uma das instituições mais tradicionais de Belém, atendendo principalmente pelo SUS.",
    },
    {
      "name": "Hospital Porto Dias",
      "address": "Av. Almirante Barroso",
      "distance": "3.1 km",
      "status": "Atendimento 24h",
      "rating": "4.7",
      "type": "Particular",
      "history":
          "O Hospital Porto Dias é um dos mais modernos da região, com equipamentos de última geração e atendimento premium.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Hospitais em Belém',
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
              colors: [Color(0xFFD32F2F), Color(0xFFE57373)],
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
                hintText: "Buscar hospital...",
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
                "🏥 ${hospitals.length} hospitais disponíveis",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ),
          ),

          /// LISTA
          Expanded(
            child: ListView.builder(
              itemCount: hospitals.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                var hospital = hospitals[index];

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
                                  const Icon(Icons.local_hospital,
                                      color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(
                                    hospital["name"]!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text("${hospital["rating"]} ⭐"),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// ENDEREÇO
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14),
                              const SizedBox(width: 4),
                              Text(hospital["address"]!),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// TIPO
                          Row(
                            children: [
                              const Icon(Icons.category, size: 14),
                              const SizedBox(width: 4),
                              Text(hospital["type"]!),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// STATUS + DISTÂNCIA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(hospital["status"]!,
                                  style: const TextStyle(color: Colors.green)),
                              Text(hospital["distance"]!),
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
                                    _mostrarDetalhes(context, hospital),
                              ),

                              /// COMPARTILHAR
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () => _compartilhar(hospital),
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
  void _mostrarDetalhes(BuildContext context, Map<String, String> hospital) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(hospital["name"]!),
        content: Text(hospital["history"]!),
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
  void _compartilhar(Map<String, String> hospital) {
    Share.share(
      "Hospital: ${hospital["name"]}\nEndereço: ${hospital["address"]}",
    );
  }
}