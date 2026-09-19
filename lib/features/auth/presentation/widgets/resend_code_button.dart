import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// Botón de reenvío de código con cooldown animado.
class ResendCodeButton extends StatelessWidget {
  const ResendCodeButton({
    super.key,
    required this.cooldownSeconds,
    required this.totalSeconds,
    required this.isResending,
    required this.onPressed,
  });

  final int cooldownSeconds;
  final int totalSeconds;
  final bool isResending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final canResend = cooldownSeconds <= 0 && !isResending;

    if (canResend) {
      return SkyButton(
        label: '¿No te llegó? Reenviar código',
        variant: SkyButtonVariant.ghost,
        size: SkyButtonSize.sm,
        loading: isResending,
        onPressed: onPressed,
      );
    }

    final progress = totalSeconds == 0
        ? 0.0
        : 1 - (cooldownSeconds / totalSeconds).clamp(0.0, 1.0);
    final minutes = cooldownSeconds ~/ 60;
    final seconds = cooldownSeconds % 60;
    final timeLabel = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Podrás reenviar el código en $timeLabel',
          style: typography.caption.copyWith(color: colors.subtle),
        ),
        const SizedBox(height: SkySpacing.xxs),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: SkyMotion.base,
          curve: SkyMotion.standard,
          builder: (context, value, _) => SkyProgressBar(value: value),
        ),
      ],
    );
  }
}
