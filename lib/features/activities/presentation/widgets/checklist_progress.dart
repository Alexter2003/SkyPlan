import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// Progreso del checklist de una ubicación: "2 de 5" con barra. Oculto si
/// no hay actividades que hacer.
class ChecklistProgress extends StatelessWidget {
  const ChecklistProgress({
    super.key,
    required this.done,
    required this.total,
    this.visitFinished = false,
  });

  final int done;
  final int total;

  /// La ubicación ya quedó finalizada (todas las actividades completas).
  final bool visitFinished;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$done de $total completadas',
                key: const ValueKey('checklist-progress'),
                style: typography.label,
              ),
            ),
            if (visitFinished)
              SkyBadge(
                label: 'Ubicación finalizada',
                background: colors.statusApt.background,
                foreground: colors.statusApt.foreground,
              ),
          ],
        ),
        const SizedBox(height: SkySpacing.xxs),
        SkyProgressBar(
          value: done / total,
          color: done == total
              ? colors.statusApt.background
              : colors.primaryBlue,
        ),
      ],
    );
  }
}
