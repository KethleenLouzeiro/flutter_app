import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class TerminalHidroviarioScreen extends StatelessWidget {
  final List<Map<String, String>> terminais = [
    {
      "name": "Terminal Hidroviário de Belém",
      "address": "Av. Marechal Hermes - Campina",
      "distance": "1.2 km",
      "status": "Funcionando 24h",
      "rating": "4.7",
      "type": "Terminal Hidroviário",
      "history":
          "Principal terminal hidroviário de Belém, com embarcações para ilhas e municípios do Pará.",
    },
    {
      "name": "Porto do Açaí",
      "address": "Ver-o-Peso",
      "distance": "2.1 km",
      "status": "Aberto 05h-22h",
      "rating": "4.5",
      "type": "Porto Regional",
      "history":
          "Importante ponto de embarque e desembarque de produtos regionais e passageiros.",
    },
    {
      "name": "Terminal de Icoaraci",
      "address": "Distrito de Icoaraci",
      "distance": "12 km",
      "status": "Funcionando 24h",
      "rating": "4.4",
      "type": "Terminal Fluvial",
      "history":
          "Terminal utilizado para transporte de passageiros e cargas para ilhas próximas.",
    },
    {
      "name": "Porto da Praça Princesa Isabel",
      "address": "Condor",
      "distance": "3.4 km",
      "status": "Aberto 06h-20h",
      "rating": "4.3",
      "type": "Porto Urbano",
      "history":
          "Área utilizada para transporte fluvial urbano e travessias locais.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Terminais Hidroviários',
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
              colors: [Color(0xFF00695C), Color(0xFF26A69A)],
            ),
          ),
        ),
      ),

      body: Column(
        children: [

          /// BUSCA
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar terminal hidroviário...",
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
                "🚢 ${terminais.length} terminais disponíveis",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00695C),
                ),
              ),
            ),
          ),

          /// LISTA
          Expanded(
            child: ListView.builder(
              itemCount: terminais.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                var terminal = terminais[index];

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
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.directions_boat,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    terminal["name"]!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text("${terminal["rating"]} ⭐"),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// ENDEREÇO
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(terminal["address"]!),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// TIPO
                          Row(
                            children: [
                              const Icon(Icons.category, size: 14),
                              const SizedBox(width: 4),
                              Text(terminal["type"]!),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// STATUS + DISTÂNCIA
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                terminal["status"]!,
                                style:
                                    const TextStyle(color: Colors.green),
                              ),
                              Text(terminal["distance"]!),
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
                                onPressed: () => _mostrarDetalhes(
                                  context,
                                  terminal,
                                ),
                              ),

                              /// COMPARTILHAR
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () =>
                                    _compartilhar(terminal),
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
    Map<String, String> terminal,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(terminal["name"]!),
        content: Text(terminal["history"]!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  /// COMPARTILHAR
  void _compartilhar(Map<String, String> terminal) {
    Share.share(
      "Terminal Hidroviário: ${terminal["name"]}\n"
      "Endereço: ${terminal["address"]}",
    );
  }
}