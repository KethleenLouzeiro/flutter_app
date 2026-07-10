import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/user_local_keys.dart';

class ViageBemTutorial {
  static String? get currentPreferenceKey {
    final uid = UserLocalKeys.currentUid;
    return uid == null ? null : UserLocalKeys.tutorialVisto(uid);
  }

  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final key = currentPreferenceKey;
    final alreadySeen = key != null && (prefs.getBool(key) ?? false);

    if (alreadySeen || !context.mounted) return;

    await show(context);
  }

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _TutorialDialog(),
    );
  }

  static Future<void> markAsSeen() async {
    final key = currentPreferenceKey;

    if (key == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }
}

class _TutorialDialog extends StatefulWidget {
  const _TutorialDialog();

  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<_TutorialDialog> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _steps.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ViageBemTutorial.markAsSeen();

    if (!mounted) return;

    Navigator.pop(context);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Pular'),
                ),
              ),
              SizedBox(
                height: 300,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _steps.length,
                  onPageChanged: (value) {
                    setState(() {
                      _index = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    final step = _steps[index];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: step.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            step.icon,
                            color: step.color,
                            size: 42,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF111827),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  final selected = index == _index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 26 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(_isLast ? 'Começar' : 'Próximo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialStep {
  const _TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

const List<_TutorialStep> _steps = [
  _TutorialStep(
    title: 'Bem-vindo ao ViageBem',
    description:
        'Encontre locais úteis no mapa para planejar melhor sua viagem.',
    icon: Icons.explore_rounded,
    color: Color(0xFF2563EB),
  ),
  _TutorialStep(
    title: 'Pesquisa',
    description:
        'Busque destinos, hotéis, restaurantes, hospitais, postos e outros pontos de apoio.',
    icon: Icons.search_rounded,
    color: Color(0xFF6A43B8),
  ),
  _TutorialStep(
    title: 'Filtros',
    description:
        'Use os filtros para mostrar no mapa apenas a categoria que você precisa.',
    icon: Icons.tune_rounded,
    color: Color(0xFFFF6A00),
  ),
  _TutorialStep(
    title: 'Rotas',
    description:
        'Toque em um local e trace a rota dentro do próprio ViageBem, sem sair do app.',
    icon: Icons.route_rounded,
    color: Color(0xFF43B84D),
  ),
  _TutorialStep(
    title: 'Favoritos',
    description: 'Salve locais importantes para acessar rapidamente depois.',
    icon: Icons.favorite_rounded,
    color: Color(0xFFE53935),
  ),
];
