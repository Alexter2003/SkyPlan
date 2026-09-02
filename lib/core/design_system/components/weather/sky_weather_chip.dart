import 'package:flutter/material.dart';

import '../../icons/sky_icon.dart';
import '../../tokens/sky_colors.dart';
import '../../tokens/sky_typography.dart';

enum SkyWeatherCondition { sunny, cloudy, rainy }

/// Shows a weather reading (e.g. "24°C Soleado") the way the activity card
/// in the design canvas does — icon + temperature + condition, filled with
/// the brand blue.
class SkyWeatherChip extends StatelessWidget {
  const SkyWeatherChip({
    super.key,
    required this.temperatureCelsius,
    required this.condition,
  });

  final int temperatureCelsius;
  final SkyWeatherCondition condition;

  SkyIconType get _icon => switch (condition) {
    SkyWeatherCondition.sunny => SkyIconType.sun,
    SkyWeatherCondition.cloudy => SkyIconType.cloud,
    SkyWeatherCondition.rainy => SkyIconType.rain,
  };

  String get _label => switch (condition) {
    SkyWeatherCondition.sunny => 'Soleado',
    SkyWeatherCondition.cloudy => 'Nublado',
    SkyWeatherCondition.rainy => 'Lluvia',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primaryBlue,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkyIcon(_icon, size: 16, color: colors.onAccent),
          const SizedBox(width: 6),
          Text(
            '$temperatureCelsius°C $_label',
            style: typography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onAccent,
            ),
          ),
        ],
      ),
    );
  }
}
