import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_typography.dart';

/// The apto / precaución / posponer indicator (requirement 5.e:
/// "indicador de probabilidad de realización... según el tipo de actividad
/// y el clima"). Reads its colors from [SkyColors.statusColor] — never
/// hard-code green/amber/red here or in call sites.
class SkyStatusIndicator extends StatelessWidget {
  const SkyStatusIndicator({super.key, required this.status});

  final SkyStatus status;

  String get _label => switch (status) {
    SkyStatus.apt => 'Apto',
    SkyStatus.caution => 'Precaución',
    SkyStatus.postpone => 'Posponer',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final statusColor = colors.statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusColor.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _label.toUpperCase(),
            style: typography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: statusColor.foreground,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
