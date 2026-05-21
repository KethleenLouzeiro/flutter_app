import 'package:flutter/material.dart';
import 'views/splash_view.dart'; // import da tela
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
const String accessToken =
    String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
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
        textSelectionTheme: const TextSelectionThemeData(
  cursorColor: Colors.red,
  selectionColor: Colors.redAccent,
  selectionHandleColor: Colors.red,
),
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),

      // Tela inicial agora vem de outro arquivo
      home: const SplashView(),
    );
  }
}
