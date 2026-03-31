
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class WorkshopsScreen extends StatelessWidget {
  const WorkshopsScreen({super.key});

  static final List<Map<String, String>> workshops = [
    {
      "name": "Oficina Mecânica",
      "location": "Av. Nazaré, 1500",
      "description":
          "Serviços completos de manutenção preventiva e corretiva para carros e motos. Revisão geral, troca de óleo, filtros e diagnóstico eletrônico.",
      "status": "Aberto 24h",
      "distance": "2.3 km",
      "rating": "4.5",
    },
    {
      "name": "Especialista em Injeção Eletrônica",
      "location": "Rua dos Carros, 250",
      "description":
          "Diagnóstico e reparo de sistemas de injeção eletrônica, sensores, atuadores e módulos ECU.",
      "status": "Aberto 24h",
      "distance": "1.8 km",
      "rating": "4.5",
    },
    {
      "name": "Oficina de Suspensão e Direção",
      "location": "Av. Almirante Barroso, 800",
      "description":
          "Especializada em suspensão, direção, freios e alinhamento.",
      "status": "Aberto 24h",
      "distance": "3.1 km",
      "rating": "4.5",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final spots = workshops;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Oficinas Mecânicas em Belém',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)],
            ),
          ),
        ),
      ),

      body: Column(
        children: [

          /// 🔍 BUSCA
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar oficinas...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          /// 🗺️ MAPA (CORRIGIDO - SEM TOKEN)
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Image.network(
                    'https://maps.googleapis.com/maps/api/staticmap?center=-1.45,-48.49&zoom=12&size=600x300&maptype=roadmap',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: Colors.blue[100],
                        child: const Center(
                          child: Text("Mapa indisponível"),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      color: Colors.white,
                      child: const Text(
                        "Mapa de Belém",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// 📍 LISTA
          Expanded(
            child: ListView.builder(
              itemCount: spots.length,
              itemBuilder: (context, index) {
                var spot = spots[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(spot["name"]!),
                    subtitle: Text(spot["location"]!),
                    trailing: Text("${spot["rating"]} ⭐"),
                    onTap: () => _mostraHistoria(context, spot),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostraHistoria(BuildContext context, Map<String, String> spot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(spot["name"]!),
        content: Text(spot["description"]!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  void _compartilharSpot(Map<String, String> spot) {
    Share.share(
      "Confira esta oficina:\n${spot["name"]}\n${spot["location"]}",
    );
  }

  void _abrirRotaSpot(Map<String, String> spot) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(spot["location"]!)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

