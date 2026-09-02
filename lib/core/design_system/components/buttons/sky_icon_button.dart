import 'package:flutter/material.dart';

import '../../icons/sky_icon.dart';
import '../../tokens/sky_colors.dart';
import '../../tokens/sky_shapes.dart';

/// A square, 44x44 minimum icon-only button (app bar actions, list-item
/// trailing actions) using [SkyIcon] instead of Material icons.
class SkyIconButton extends StatelessWidget {
  const SkyIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.filled = false,
  });

  final SkyIconType icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  /// Filled uses [SkyColors.surface] + border, like a secondary button;
  /// unfilled is transparent (default app-bar look).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final shapes = context.skyShapes;

    final button = Material(
      color: filled ? colors.surface : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: shapes.radiusMd,
        side: filled
            ? BorderSide(color: colors.ink, width: shapes.borderThin)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: shapes.radiusMd,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(child: SkyIcon(icon, size: 22, color: colors.ink)),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
