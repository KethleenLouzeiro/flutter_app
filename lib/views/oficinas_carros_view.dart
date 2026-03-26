// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:share_plus/share_plus.dart';


// class WorkshopsScreen extends StatelessWidget {
//   const WorkshopsScreen({super.key});
//   static final List<Map<String, String>> workshops = [
//     {
//       "name": "Oficina Mecânica",
//       "location": "Av. Nazaré, 1500",
//       "description": "Serviços completos de manutenção preventiva e corretiva para carros e motos. Revisão geral, troca de óleo, filtros e diagnóstico eletrônico.",
//       "status": "Aberto 24h",
//       "distance": "2.3 km",
//       "rating": "4.5",
//     }, 
//     {
//       "name": "Especialista em Injeção Eletrônica",
//       "location": "Rua dos Carros, 250",
//       "description": "Diagnóstico e reparo de sistemas de injeção eletrônica, sensores, atuadores e módulos ECU. Trabalhos em carros nacionais e importados.",
//       "status": "Aberto 24h",
//       "distance": "1.8 km",
//       "rating": "4.5",
//     },
//     {
//       "name": "Oficina de Suspensão e Direção",
//       "location": "Av. Almirante Barroso, 800",
//       "description": "Especializada em suspensão, direção, freios e alinhamento. Trabalhos em carros, motos e veículos comerciais.",
//       "status": "Aberto 24h",
//       "distance": "3.1 km",
//       "rating": "4.5",
//     },
//     {
//       "name": "Centro de Ar Condicionado Automotivo",
//       "location": "Travessa Padre Eutíquio, 45",
//       "description": "Recarga, reparo e manutenção de sistemas de ar condicionado automotivo. Limpeza de dutos e substituição de componentes.",
//       "status": "Aberto 24h",
//       "distance": "2.7 km",
//       "rating": "4.5",
//     },
//     {
//       "name": "Oficina de Motores a Combustão",
//       "location": "Av. João Paulo II, 1200",
//       "description": "Recondicionamento de motores, cabeçotes, bielas e pistões. Trabalhos em motores a gasolina, álcool e diesel.",
//        "status": "Aberto 24h",
//       "distance": "4.0 km",
//       "rating": "4.5",
//     },
//     {
//       "name": "Especialista em Transmissão",
//       "location": "Rua 15 de Novembro, 300",
//       "description": "Reparo e manutenção de caixas de câmbio manual e automática, diferenciais, embreagens e sistemas de tração 4x4.",
//        "status": "Aberto 24h",
//       "distance": "3.5 km",
//       "rating": "4.5",
//     },
//     {
//       "name": "Oficina Elétrica e Eletrônica",
//       "location": "Av. Gentil Bittencourt, 500",
//       "description": "Instalação e reparo de sistemas elétricos, bateria, alternador, motor de partida, painéis e central multimídia.",
//       "status": "Aberto 24h",
//       "distance": "2.9 km",
//       "rating": "4.5",
//     },
//     {
//       "name": "Centro de Funilaria e Pintura",
//       "location": "Rua do Carmo, 180",
//       "description": "Reparos de lataria, funilaria, pintura automotiva e polimento. Recuperação de veículos após acidentes.",
//       "status": "Aberto 24h",
//       "distance": "3.8 km",
//       "rating": "4.5",
//     },
//     {
//       "name": "Oficina de Motos e Scooters",
//       "location": "Av. Portugal, 750",
//       "description": "Especializada em manutenção preventiva e corretiva de motocicletas, scooters e ciclomotores de todas as marcas.",
//       "status": "Aberto 24h",
//       "distance": "2.4 km",
//       "rating": "4.5",
//     },
//     {
//       "name": "Centro de Diagnóstico Automotivo",
//       "location": "Rua dos Mundurucus, 90",
//       "description": "Diagnóstico computadorizado completo com equipamentos de última geração. Leitura de códigos de falha e testes funcionais.",
//       "status": "Aberto 24h",
//       "distance": "3.2 km",
//       "rating": "4.5",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//   final spots = workshops;
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         title: const Text(
//           'Oficinas Mecanicas em Belem',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.w800,
//             color: Colors.white,
//             letterSpacing: -0.5,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           /// BARRA DE BUSCA E FILTRO
//           Container(
//             padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: "Buscar oficinas...",
//                       hintStyle: TextStyle(
//                         color: Colors.grey[400],
//                         fontSize: 14,
//                       ),
//                       prefixIcon: Icon(
//                         Icons.search_rounded,
//                         color: Colors.grey[500],
//                         size: 22,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         borderSide: BorderSide(
//                           color: Colors.grey[200]!,
//                           width: 1.5,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         borderSide: BorderSide(
//                           color: Colors.grey[200]!,
//                           width: 1.5,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         borderSide: const BorderSide(
//                           color: Color(0xFF0D47A1),
//                           width: 2,
//                         ),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(vertical: 13),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF0D47A1).withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.tune_rounded,
//                       color: Colors.white,
//                       size: 22,
//                     ),
//                     onPressed: () {},
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           /// MAPA TURÍSTICO
//           Container(
//             height: 200,
//             width: double.infinity,
//             margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(18),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blue.withOpacity(0.15),
//                   blurRadius: 16,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(18),
//               child: Stack(
//                 children: [
//                   // Imagem de fundo do mapa
//                   Image.network(
//                     'https://api.mapbox.com/styles/v1/mapbox/streets-v12/static/-48.5,-1.45,12,0,0/400x250@2x?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B6MA',
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: 200,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         color: Colors.blue[100],
//                         child: Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.map,
//                                 size: 48,
//                                 color: Colors.blue[700],
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Mapa de Belém',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.blue[900],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   // Overlay com gradiente
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.2),
//                         ],
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                       ),
//                     ),
//                   ),
//                   // Texto no topo com fundo
//                   Positioned(
//                     top: 12,
//                     left: 12,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.95),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.15),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.location_on_rounded,
//                             size: 14,
//                             color: const Color(0xFF0D47A1),
//                           ),
//                           const SizedBox(width: 6),
//                           const Flexible(
//                             child: Text(
//                               'Mapa dos pontos de oficinas de carros de Belém',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color(0xFF1A1A1A),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           /// HEADER: Pontos de oficinas mecanicas de carros
//           Padding(
//             padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "🏛️ buscar oficinas mecanicas",
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                       color: const Color(0xFF0D47A1),
//                       letterSpacing: -0.3,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     "${spots.length} atrações imperdíveis na região",
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[500],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           /// LISTA DE PONTOS TURÍSTICOS
//           Expanded(
//             child: ListView.builder(
//               itemCount: spots.length,
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//               itemBuilder: (context, index) {
//                 var spot = spots[index];

//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 10),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFF0D47A1).withOpacity(0.12),
//                         blurRadius: 16,
//                         offset: const Offset(0, 6),
//                       ),
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.04),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Card(
//                     margin: EdgeInsets.zero,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18),
//                     ),
//                     elevation: 0,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(18),
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.white,
//                             const Color(0xFF0D47A1).withOpacity(0.02),
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         border: Border.all(
//                           color: const Color(0xFF0D47A1).withOpacity(0.08),
//                           width: 1,
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Header: Nome e Rating
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Expanded(
//                                   child: Row(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(7),
//                                         decoration: BoxDecoration(
//                                           gradient: const LinearGradient(
//                                             colors: [
//                                               Color(0xFF0D47A1),
//                                               Color(0xFF1565C0),
//                                             ],
//                                             begin: Alignment.topLeft,
//                                             end: Alignment.bottomRight,
//                                           ),
//                                           borderRadius: BorderRadius.circular(
//                                             12,
//                                           ),
//                                         ),
//                                         child: const Icon(
//                                           Icons.location_on_rounded,
//                                           color: Colors.white,
//                                           size: 16,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Expanded(
//                                         child: Text(
//                                           spot["name"]!,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.w800,
//                                             fontSize: 14,
//                                             color: Color(0xFF0D47A1),
//                                             letterSpacing: -0.2,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 11,
//                                     vertical: 5,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     gradient: const LinearGradient(
//                                       colors: [
//                                         Color(0xFFFFB300),
//                                         Color(0xFFFFC107),
//                                       ],
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                     ),
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: const Color(
//                                           0xFFFFC107,
//                                         ).withOpacity(0.25),
//                                         blurRadius: 8,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Icon(
//                                         Icons.star_rounded,
//                                         color: Colors.white,
//                                         size: 13,
//                                       ),
//                                       const SizedBox(width: 3),
//                                       Text(
//                                         spot["rating"]!,
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.w800,
//                                           color: Colors.white,
//                                           fontSize: 11,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 6),
//                             Divider(
//                               height: 1,
//                               color: const Color(0xFF0D47A1).withOpacity(0.1),
//                             ),
//                             const SizedBox(height: 6),
//                             // Endereço
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.location_on_rounded,
//                                   size: 15,
//                                   color: const Color(0xFFD32F2F),
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Expanded(
//                                   child: Text(
//                                     spot["location"]!,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(
//                                       color: Colors.grey[700],
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 5),
//                             // Tipo de Atração
//                             // Row(
//                               // children: [
//                               //   Flexible(
//                               //     child: Container(
//                               //       padding: const EdgeInsets.symmetric(
//                               //         horizontal: 8,
//                               //         vertical: 3,
//                               //       ),
//                               //       decoration: BoxDecoration(
//                               //         // color: const Color(
//                               //           0xFF6A1B9A,
//                               //         ).withOpacity(0.1),
//                               //         borderRadius: BorderRadius.circular(8),
//                               //       ),
//                               //       child: Row(
//                               //         mainAxisSize: MainAxisSize.min,
//                               //         children: [
//                               //           Icon(
//                               //             Icons.category_rounded,
//                               //             size: 12,
//                               //             color: const Color(0xFF6A1B9A),
//                               //           ),
//                               //           const SizedBox(width: 3),
//                                         // // Flexible(
//                                         // //   // child: Text(
//                                         // //   //   spot["type"]!,
//                                         // //   //   maxLines: 1,
//                                         // //   //   overflow: TextOverflow.ellipsis,
//                                         // //   //   style: const TextStyle(
//                                         // //   //     color: Color(0xFF6A1B9A),
//                                         // //   //     fontWeight: FontWeight.w700,
//                                         // //   //     fontSize: 9,
//                                         // //   //   ),
//                             //             // //   // ),
//                             //             // ),
//                             //           ],
//                             //         ),
//                             //       ),
//                             //     ),
//                             //   ],
//                             // ),
//                             const SizedBox(height: 5),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 // Horário de Funcionamento
//                                 Expanded(
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         Icons.access_time_rounded,
//                                         size: 15,
//                                         color: const Color(0xFF388E3C),
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Expanded(
//                                         child: Text(
//                                           spot["status"]!,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: const TextStyle(
//                                             color: Color(0xFF388E3C),
//                                             fontWeight: FontWeight.w800,
//                                             fontSize: 11,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 // Distância
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 9,
//                                     vertical: 3,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: const Color(
//                                       0xFF0D47A1,
//                                     ).withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(
//                                         Icons.directions_car_rounded,
//                                         size: 13,
//                                         color: const Color(0xFF0D47A1),
//                                       ),
//                                       const SizedBox(width: 3),
//                                       Text(
//                                         spot["distance"]!,
//                                         style: const TextStyle(
//                                           color: Color(0xFF0D47A1),
//                                           fontWeight: FontWeight.w800,
//                                           fontSize: 10,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 // Botão de História
//                                 GestureDetector(
//                                   onTap: () => _mostraHistoria(context, spot),
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
//                                         begin: Alignment.topLeft,
//                                         end: Alignment.bottomRight,
//                                       ),
//                                       borderRadius: BorderRadius.circular(8),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.05),
//                                           blurRadius: 4,
//                                           offset: Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Icon(
//                                       Icons.info_outline_rounded,
//                                       color: Color.fromARGB(255, 45, 43, 48),
//                                       size: 16,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 // Botão de Compartilhar
//                                 GestureDetector(
//                                   onTap: () => _compartilharSpot(spot),
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
//                                         begin: Alignment.topLeft,
//                                         end: Alignment.bottomRight,
//                                       ),
//                                       borderRadius: BorderRadius.circular(8),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.05),
//                                           blurRadius: 4,
//                                           offset: Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Icon(
//                                       Icons.share_rounded,
//                                       color: Color(0xFF374151),
//                                       size: 16,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 // Botão de Rota
//                                 GestureDetector(
//                                   onTap: () => _abrirRotaSpot(spot),
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
//                                         begin: Alignment.topLeft,
//                                         end: Alignment.bottomRight,
//                                       ),
//                                       borderRadius: BorderRadius.circular(8),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.05),
//                                           blurRadius: 4,
//                                           offset: Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Icon(
//                                       Icons.directions_rounded,
//                                       color: Color(0xFF374151),
//                                       size: 16,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _mostraHistoria(BuildContext context, Map<String, String> spot) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           insetPadding: const EdgeInsets.all(16),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.75,
//               maxWidth: MediaQuery.of(context).size.width - 32,
//             ),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.white,
//                     const Color.fromARGB(255, 186, 204, 191).withOpacity(0.05),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Header
//                   Container(
//                     padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Color.fromARGB(255, 38, 104, 49), Color.fromARGB(255, 31, 116, 80)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(
//                           Icons.history_edu_rounded,
//                           color: Colors.white,
//                           size: 28,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Informacoes',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 spot["name"]!,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close, color: Colors.white),
//                           onPressed: () => Navigator.pop(context),
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(
//                             minWidth: 40,
//                             minHeight: 40,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Conteúdo
//                   Flexible(
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(20),
//                       child: Text(
//                         spot["description"]!,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[700],
//                           height: 1.6,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // Botão de fechar
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                     child: SizedBox(
//                       width: double.infinity,
//                       height: 48,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF7C3AED),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text(
//                           'Fechar',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

// void _compartilharSpot(Map<String, String> spot) {
//   final String texto =
//       '''
// Confira esta oficina:
// Nome: ${spot["name"]}
// Endereço: ${spot["location"]}
// Horário: ${spot["status"]}
// Distância: ${spot["distance"]}

// Descrição: ${spot["description"]}
// ''';

//   Share.share(texto);
// }

//   void _abrirRotaSpot(Map<String, String> spot) async {
//     final String endereco = spot["location"]!;
//     final String url =
//         'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(endereco)}';
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url));
//     } else {
//       // Fallback ou erro
//       throw 'Não foi possível abrir o mapa';
//     }
//   }
// }
