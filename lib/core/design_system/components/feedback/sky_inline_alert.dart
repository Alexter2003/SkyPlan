import 'package:flutter/material.dart';

import '../../icons/sky_icon.dart';
import '../../tokens/sky_colors.dart';
import '../../tokens/sky_motion.dart';
import '../../tokens/sky_shapes.dart';
import '../../tokens/sky_spacing.dart';
import '../../tokens/sky_typography.dart';

enum SkyInlineAlertTone { error, warning, info }

/// Banner de error/aviso dentro de un formulario (a diferencia de
/// [SkySnackbar], que desaparece solo).
class SkyInlineAlert extends StatelessWidget {
  const SkyInlineAlert({
    super.key,
    required this.message,
    this.tone = SkyInlineAlertTone.error,
    this.details,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final SkyInlineAlertTone tone;
  final List<String>? details;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final shapes = context.skyShapes;

    final (
      Color background,
      Color foreground,
      SkyIconType icon,
    ) = switch (tone) {
      SkyInlineAlertTone.error => (
        colors.statusPostpone.background,
        colors.statusPostpone.foreground,
        SkyIconType.warning,
      ),
      SkyInlineAlertTone.warning => (
        colors.statusCaution.background,
        colors.statusCaution.foreground,
        SkyIconType.warning,
      ),
      SkyInlineAlertTone.info => (
        colors.primaryBlue,
        colors.onAccent,
        SkyIconType.mail,
      ),
    };

    return AnimatedContainer(
      duration: SkyMotion.base,
      curve: SkyMotion.standard,
      padding: const EdgeInsets.all(SkySpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: shapes.radiusMd,
        border: Border.all(color: colors.ink, width: shapes.borderThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkyIcon(icon, size: 18, color: foreground),
          const SizedBox(width: SkySpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: typography.bodyStrong.copyWith(color: foreground),
                ),
                for (final detail in details ?? const <String>[])
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '• $detail',
                      style: typography.caption.copyWith(color: foreground),
                    ),
                  ),
                if (actionLabel != null && onAction != null)
                  Padding(
                    padding: const EdgeInsets.only(top: SkySpacing.xxs),
                    child: GestureDetector(
                      onTap: onAction,
                      child: Text(
                        actionLabel!,
                        style: typography.bodyStrong.copyWith(
                          color: foreground,
                          decoration: TextDecoration.underline,
                          decorationColor: foreground,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
