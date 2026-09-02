import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_typography.dart';

/// Single-value slider (e.g. minimum acceptable temperature for an outdoor
/// activity) with a label showing [valueLabel] above the track.
class SkySlider extends StatelessWidget {
  const SkySlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.valueLabel,
    this.label,
    this.divisions,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String valueLabel;
  final String? label;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (label != null) Text(label!, style: typography.label),
            Text(valueLabel, style: typography.bodyStrong),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: colors.primaryBlue,
            inactiveTrackColor: colors.border,
            thumbColor: colors.ink,
            overlayColor: colors.primaryBlue.withValues(alpha: 0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
