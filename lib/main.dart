import 'package:flutter/material.dart';
import 'views/home_view.dart'; // import da tela

void main() {
  runApp(const MyApp());
}

/// Widget principal do aplicativo
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Cadastro Flutter',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),

      // Tela inicial agora vem de outro arquivo
      home: const HomeView(),
    );
  }
}
