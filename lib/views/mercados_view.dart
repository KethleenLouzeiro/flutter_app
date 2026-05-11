import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});

  static final List<Map<String, String>> markets = [
    {
      "name": "Líder Supermercados",
      "location": "Av. Almirante Barroso, 2000",
      "description":
          "Grande variedade de produtos, hortifruti, padaria e açougue.",
      "status": "Aberto",
      "distance": "2.1 km",
      "rating": "4.4",
    },
    {
      "name": "Supermercado Nazaré",
      "location": "Av. Nazaré, 1200",
      "description":
          "Rede tradicional com preços acessíveis e boa variedade.",
      "status": "Aberto",
      "distance": "1.5 km",
      "rating": "4.3",
    },
    {
      "name": "Formosa Supermercados",
      "location": "Av. Augusto Montenegro, 3500",
      "description":
          "Supermercado completo com estacionamento e promoções frequentes.",
      "status": "Aberto",
      "distance": "3.8 km",
      "rating": "4.5",
    },
    {
      "name": "Assaí Atacadista",
      "location": "Rod. BR-316, Km 2",
      "description":
          "Atacado com preços baixos para compras em grande quantidade.",
      "status": "Aberto",
      "distance": "4.2 km",
      "rating": "4.6",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Mercados em Belém"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
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
                hintText: "Buscar mercados...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// 📍 LISTA
          Expanded(
            child: ListView.builder(
              itemCount: markets.length,
              itemBuilder: (context, index) {
                final market = markets[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_grocery_store,
                      color: Colors.green,
                    ),

                    title: Text(
                      market["name"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(market["location"]!),
                        Text("${market["distance"]} • ${market["status"]}"),
                      ],
                    ),

                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${market["rating"]} ⭐"),
                      ],
                    ),

                    onTap: () => _mostrarDetalhes(context, market),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 📌 DIALOG DETALHADO
  void _mostrarDetalhes(BuildContext context, Map<String, String> market) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(market["name"]!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(market["description"]!),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 5),
                Expanded(child: Text(market["location"]!)),
              ],
            ),
          ],
        ),
        actions: [

          /// 📤 COMPARTILHAR
          IconButton(
            icon: const Icon(Icons.share, color: Colors.green),
            onPressed: () => _compartilhar(market),
          ),

          /// 🧭 ABRIR LOCAL NO MAPA (opcional link externo)
          IconButton(
            icon: const Icon(Icons.map, color: Colors.blue),
            onPressed: () => _abrirMapa(market),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  /// 📤 COMPARTILHAR
  void _compartilhar(Map<String, String> market) {
    Share.share(
      "Confira este mercado:\n${market["name"]}\n${market["location"]}",
    );
  }

  /// 🧭 ABRIR NO GOOGLE MAPS (SEM EMBUTIR MAPA)
  void _abrirMapa(Map<String, String> market) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(market["location"]!)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}