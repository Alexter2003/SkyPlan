import 'package:flutter/material.dart';

import '../../icons/sky_icon.dart';
import '../../tokens/sky_colors.dart';
import '../../tokens/sky_motion.dart';
import '../../tokens/sky_shapes.dart';
import '../../tokens/sky_typography.dart';

/// Square checkbox with an optional label — the "marcar actividad como
/// finalizada/completada" checklist item on the Pendientes screen
/// (requirement 5.c) uses this.
class SkyCheckbox extends StatelessWidget {
  const SkyCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.strikeLabelWhenChecked = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final bool strikeLabelWhenChecked;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final shapes = context.skyShapes;

    final box = AnimatedContainer(
      duration: SkyMotion.fast,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: value ? colors.primaryBlue : colors.surface,
        borderRadius: shapes.radiusXs,
        border: Border.all(color: colors.ink, width: shapes.borderThin),
      ),
      child: value
          ? SkyIcon(SkyIconType.check, size: 16, color: colors.onAccent)
          : null,
    );

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: shapes.radiusXs,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            box,
            if (label != null) ...[
              const SizedBox(width: 10),
              Text(
                label!,
                style: typography.body.copyWith(
                  decoration: strikeLabelWhenChecked && value
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: strikeLabelWhenChecked && value
                      ? colors.subtle
                      : colors.ink,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
