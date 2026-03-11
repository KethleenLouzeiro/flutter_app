import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/views/welcome_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin { //permite animação sincronizada

  late AnimationController _controller; //controla o progresso da animação

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controller.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeView()),
      );
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF1E293B),
            ],
          ),
        ),
               child: Stack(
               children: [

               Positioned.fill(
               child: Image.asset(
               'assets/images/logo.png',
               fit: BoxFit.cover,
               alignment: Alignment.topCenter,
               ),
               ),

               Positioned(
               bottom: 100,
               left: 0,
               right: 0,
               child: Center(
child: AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {

    double scale = 1 + (_controller.value * 0.3);

    return Transform.scale(
      scale: scale,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha:0.6),
              blurRadius: 28 * _controller.value,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.location_on,
          size: 60,
          color: Colors.orange,
        ),
      ),
    );
  },
),
      ),
    ),
  ],
),
      ),
    );
  }
}

