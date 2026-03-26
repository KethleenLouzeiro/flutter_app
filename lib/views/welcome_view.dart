import 'package:flutter/material.dart';
import 'cadastro_view.dart';
import 'dashboard_view.dart';
import 'Postos_view.dart';
import 'pontosturisticos_view.dart';
import 'oficinas_carros_view.dart';


class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            //
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Ilustração / ícone principal
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.18),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 90,
                  color: Color(0xFF6366F1),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'Pronto para começar?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Crie sua conta para salvar seus dados ou pule e explore o app agora mesmo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Botões
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardView(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6366F1),
                          elevation: 2,
                          side: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 1.5,
                          ),
                        ),
                        child: const Text("Continuar cadastro"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GasStationsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Postos de combustivel'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TouristSpotsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 72, 104, 212),
                          foregroundColor: Colors.black87,
                        ),
                        child: const Text('Pontos Turísticos'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WorkshopsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            77,
                            115,
                            218,
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Oficinas Mecânicas'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CadastroView(),
                            ),
                          );
                        },
                        child: const Text('Criar minha conta'),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              Text(
                'Versão didática • Flutter',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
