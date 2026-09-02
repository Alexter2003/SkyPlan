import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_motion.dart';

/// Linear progress indicator for the "probabilidad de realización" of an
/// activity (requirement 5.e) or any 0–1 progress value.
class SkyProgressBar extends StatelessWidget {
  const SkyProgressBar({super.key, required this.value, this.color});

  /// 0.0–1.0.
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: SkyMotion.base,
        curve: SkyMotion.standard,
        builder: (context, animatedValue, _) => LinearProgressIndicator(
          value: animatedValue,
          minHeight: 8,
          backgroundColor: colors.border,
          valueColor: AlwaysStoppedAnimation(color ?? colors.primaryBlue),
        ),
      ),
    );
  }
}
