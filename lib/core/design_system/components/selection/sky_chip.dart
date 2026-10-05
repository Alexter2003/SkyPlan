import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_motion.dart';
import '../../tokens/sky_shapes.dart';
import '../../tokens/sky_typography.dart';

enum SkyChipVariant { outline, filled }

/// Filter/choice/status chip — pill-shaped, thick border, matching the
/// canvas's "ESTA SEMANA" / "ALTA PROBABILIDAD" chips. Selectable
/// (`onSelected` set) or purely informational (`onSelected: null`).
class SkyChip extends StatelessWidget {
  const SkyChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.variant = SkyChipVariant.outline,
    this.enabled = true,
    this.leading,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final SkyChipVariant variant;

  /// Deshabilitado: atenuado y sin respuesta al toque.
  final bool enabled;

  /// Icono opcional antes de la etiqueta.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final shapes = context.skyShapes;

    final filled = selected || variant == SkyChipVariant.filled;
    final background = filled ? colors.primaryBlue : colors.surface;
    final foreground = filled ? colors.onAccent : colors.ink;

    final tappable = enabled && onSelected != null;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: AnimatedContainer(
        duration: SkyMotion.fast,
        curve: SkyMotion.standard,
        decoration: BoxDecoration(
          color: background,
          borderRadius: shapes.radiusPill,
          border: Border.all(color: colors.ink, width: shapes.borderThin),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: shapes.radiusPill,
            onTap: tappable ? () => onSelected!(!selected) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 6)],
                  Flexible(
                    child: Text(
                      label,
                      style: typography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: foreground,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
