
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class OficinasScreen extends StatelessWidget {
  OficinasScreen({super.key});

  final List<Map<String, String>> oficinas = [
    {
      "name": "Oficina Mecânica Turbo Car",
      "address": "Av. Almirante Barroso - Belém",
      "distance": "2.1 km",
      "status": "Aberto 08h às 18h",
      "rating": "4.8",
      "type": "Mecânica Geral",
      "history":
          "Especializada em manutenção preventiva e corretiva, alinhamento, balanceamento e troca de óleo.",
    },
    {
      "name": "Auto Center Belém",
      "address": "Av. Augusto Montenegro",
      "distance": "4.3 km",
      "status": "Atendimento 24h",
      "rating": "4.7",
      "type": "Auto Center",
      "history":
          "Referência em serviços automotivos com equipe especializada em suspensão, freios e elétrica.",
    },
    {
      "name": "Mecânica do João",
      "address": "Tv. Padre Eutíquio",
      "distance": "1.5 km",
      "status": "Aberto 07h às 19h",
      "rating": "4.5",
      "type": "Oficina Mecânica",
      "history":
          "Atendimento rápido e confiável com foco em motores, revisão completa e diagnóstico eletrônico.",
    },
    {
      "name": "Garage Prime",
      "address": "Bairro Umarizal",
      "distance": "3.0 km",
      "status": "Aberto 09h às 20h",
      "rating": "4.9",
      "type": "Premium Auto Service",
      "history":
          "Oficina premium com serviços de estética automotiva, manutenção avançada e atendimento especializado.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),

      /// APPBAR
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Oficinas Mecânicas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF424242),
                Color(0xFF757575),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [

          /// CAMPO DE BUSCA
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Buscar oficinas...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
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
                "🔧 ${oficinas.length} oficinas disponíveis",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          /// LISTA
          Expanded(
            child: ListView.builder(
              itemCount: oficinas.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                var oficina = oficinas[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// NOME + RATING
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.build,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        oficina["name"]!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${oficina["rating"]} ⭐",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// ENDEREÇO
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  oficina["address"]!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          /// TIPO
                          Row(
                            children: [
                              Icon(
                                Icons.car_repair,
                                size: 18,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                oficina["type"]!,
                                style: const TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// STATUS + DISTÂNCIA
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Text(
                                  oficina["status"]!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                oficina["distance"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// BOTÕES
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [

                              /// DETALHES
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  // color: const Color.fromARGB(255, 236, 236, 234),
                                  
                                  borderRadius:
                                      BorderRadius.circular(12),
                                      
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Color.fromARGB(221, 211, 75, 75),
                                    size: 22,
                                  ),
                                  onPressed: () =>
                                      _mostrarDetalhes(
                                          context, oficina),
                                ),
                              ),

                              const SizedBox(width: 8),

                              /// COMPARTILHAR
                              Container(
                                // decoration: BoxDecoration(
                                //   color: Colors.grey.shade800,
                                //   borderRadius:
                                //       BorderRadius.circular(12),
                                // ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.share,
                                    color: Color.fromARGB(255, 163, 58, 58),
                                  ),
                                  onPressed: () =>
                                      _compartilhar(oficina),
                                ),
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

  /// DETALHES
  void _mostrarDetalhes(
      BuildContext context,
      Map<String, String> oficina,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          oficina["name"]!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          oficina["history"]!,
          style: const TextStyle(
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Fechar",
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// COMPARTILHAR
  void _compartilhar(Map<String, String> oficina) {
    Share.share(
      "🔧 Oficina Mecânica\n\n"
      "Nome: ${oficina["name"]}\n"
      "Endereço: ${oficina["address"]}\n"
      "Tipo: ${oficina["type"]}",
    );
  }
}



