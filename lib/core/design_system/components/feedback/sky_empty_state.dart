import 'package:flutter/material.dart';

import '../../icons/sky_icon.dart';
import '../../tokens/sky_colors.dart';
import '../../tokens/sky_typography.dart';
import '../buttons/sky_button.dart';

/// Empty list / zero-results state (e.g. "No tienes ubicaciones
/// registradas todavía"), with an optional primary action.
class SkyEmptyState extends StatelessWidget {
  const SkyEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final SkyIconType icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SkyIcon(icon, size: 40, color: colors.subtle),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: typography.title),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: typography.body.copyWith(color: colors.subtle),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              SkyButton(
                label: actionLabel!,
                onPressed: onAction,
                size: SkyButtonSize.sm,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
