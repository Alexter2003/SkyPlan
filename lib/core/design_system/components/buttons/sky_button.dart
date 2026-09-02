import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_motion.dart';
import '../../tokens/sky_shapes.dart';
import '../../tokens/sky_typography.dart';

enum SkyButtonVariant { primary, secondary, ghost, danger }

enum SkyButtonSize { sm, md, lg }

/// SkyPlan's primary call-to-action button. Wraps [InkWell] directly
/// (rather than [ElevatedButton]) so every visual property — border, radius,
/// press feedback — stays tied to [SkyColors]/[SkyShapes] tokens instead of
/// Material's default elevation/ripple styling.
///
/// All sizes are >=44px tall, per the kit's minimum hit-target rule.
class SkyButton extends StatelessWidget {
  const SkyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SkyButtonVariant.primary,
    this.size = SkyButtonSize.md,
    this.loading = false,
    this.leading,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SkyButtonVariant variant;
  final SkyButtonSize size;
  final bool loading;
  final Widget? leading;

  /// Fill the available width (typical for form primary actions).
  final bool expand;

  double get _height => switch (size) {
    SkyButtonSize.sm => 44,
    SkyButtonSize.md => 52,
    SkyButtonSize.lg => 60,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final shapes = context.skyShapes;
    final disabled = onPressed == null || loading;

    final (
      Color background,
      Color foreground,
      Color? borderColor,
    ) = switch (variant) {
      SkyButtonVariant.primary => (colors.primaryRed, colors.onAccent, null),
      SkyButtonVariant.secondary => (colors.surface, colors.ink, colors.ink),
      SkyButtonVariant.ghost => (Colors.transparent, colors.ink, null),
      SkyButtonVariant.danger => (
        colors.statusPostpone.background,
        colors.statusPostpone.foreground,
        null,
      ),
    };

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(foreground),
            ),
          )
        else if (leading != null)
          IconTheme(
            data: IconThemeData(color: foreground, size: 18),
            child: leading!,
          ),
        if (loading || leading != null) const SizedBox(width: 8),
        Text(
          label,
          style: typography.bodyStrong.copyWith(
            color: foreground,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    return AnimatedOpacity(
      duration: SkyMotion.fast,
      opacity: disabled && !loading ? 0.5 : 1,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: shapes.radiusMd,
          side: borderColor != null
              ? BorderSide(color: borderColor, width: shapes.borderThin)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: shapes.radiusMd,
          child: Container(
            height: _height,
            width: expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: content,
          ),
        ),
      ),
    );
  }
}
