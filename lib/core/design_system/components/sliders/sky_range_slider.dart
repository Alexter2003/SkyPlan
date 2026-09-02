import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_typography.dart';

/// Range slider — e.g. an acceptable temperature range, or a rain
/// probability window, when creating an activity's desired weather
/// conditions (requirement 4.b).
class SkyRangeSlider extends StatelessWidget {
  const SkyRangeSlider({
    super.key,
    required this.values,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.valuesLabel,
    this.label,
    this.divisions,
  });

  final RangeValues values;
  final double min;
  final double max;
  final ValueChanged<RangeValues> onChanged;
  final String valuesLabel;
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
            Text(valuesLabel, style: typography.bodyStrong),
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
          child: RangeSlider(
            values: values,
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
