import 'package:flutter/material.dart';

enum ViageBemMessageType {
  success,
  error,
  warning,
  info,
}

void showViageBemMessage(
  BuildContext context, {
  required String title,
  String? subtitle,
  ViageBemMessageType type = ViageBemMessageType.info,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 104),
        duration: duration,
        content: _ViageBemMessageCard(
          title: title,
          subtitle: subtitle,
          type: type,
          onClose: messenger.hideCurrentSnackBar,
        ),
      ),
    );
}

class _ViageBemMessageCard extends StatelessWidget {
  const _ViageBemMessageCard({
    required this.title,
    required this.type,
    required this.onClose,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final ViageBemMessageType type;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final style = _ViageBemMessageStyle.fromType(type);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(26),
        elevation: 12,
        shadowColor: style.iconColor.withValues(alpha: 0.18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: style.iconColor.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: style.iconColor.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  style.icon,
                  color: style.iconColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: style.textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: style.textColor.withValues(alpha: 0.70),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onClose,
                icon: Icon(
                  Icons.close_rounded,
                  color: style.textColor.withValues(alpha: 0.70),
                ),
                tooltip: 'Fechar',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViageBemMessageStyle {
  const _ViageBemMessageStyle({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  factory _ViageBemMessageStyle.fromType(ViageBemMessageType type) {
    switch (type) {
      case ViageBemMessageType.success:
        return const _ViageBemMessageStyle(
          backgroundColor: Color(0xFFFFF3E0),
          iconColor: Color(0xFFFF8A00),
          textColor: Color(0xFF0D1B3D),
          icon: Icons.check_circle_rounded,
        );
      case ViageBemMessageType.error:
        return const _ViageBemMessageStyle(
          backgroundColor: Color(0xFFFFEBEE),
          iconColor: Color(0xFFE53935),
          textColor: Color(0xFF0D1B3D),
          icon: Icons.error_rounded,
        );
      case ViageBemMessageType.warning:
        return const _ViageBemMessageStyle(
          backgroundColor: Color(0xFFFFF8E1),
          iconColor: Color(0xFFFFA000),
          textColor: Color(0xFF0D1B3D),
          icon: Icons.warning_rounded,
        );
      case ViageBemMessageType.info:
        return const _ViageBemMessageStyle(
          backgroundColor: Color(0xFFE3F2FD),
          iconColor: Color(0xFF1E88E5),
          textColor: Color(0xFF0D1B3D),
          icon: Icons.info_rounded,
        );
    }
  }
}
