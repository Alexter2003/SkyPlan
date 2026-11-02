import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../locations/presentation/widgets/weather_descriptions.dart';
import '../../domain/entities/forecast_hour.dart';

/// Resumen en lenguaje cotidiano del clima de la franja de una actividad.
class ForecastSummary extends StatelessWidget {
  const ForecastSummary({super.key, required this.forecast});

  /// `null` o vacío = todavía sin pronóstico horario.
  final List<ForecastHour>? forecast;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final hours = forecast;

    if (hours == null || hours.isEmpty) {
      return Row(
        children: [
          SkyIcon(SkyIconType.cloud, size: 16, color: colors.subtle),
          const SizedBox(width: SkySpacing.xs),
          Expanded(
            child: Text(
              'Clima pendiente de pronóstico',
              style: typography.caption.copyWith(color: colors.subtle),
            ),
          ),
        ],
      );
    }

    final cloud =
        hours.map((h) => h.cloudCover).reduce((a, b) => a + b) / hours.length;
    final rainMm = hours.map((h) => h.precipitation).reduce(math.max);
    final rainChance = hours
        .map((h) => h.precipitationProbability)
        .reduce(math.max);
    final wind = hours.map((h) => h.windSpeed).reduce(math.max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkyIcon(cloudIcon(cloud), size: 16, color: colors.ink),
        const SizedBox(width: SkySpacing.xs),
        Expanded(
          child: Text(
            '${cloudText(cloud)} · ${precipitationText(rainMm, const {})} '
            '($rainChance% de lluvia) · ${windText(wind)}',
            key: const ValueKey('forecast-summary'),
            style: typography.caption,
          ),
        ),
      ],
    );
  }
}
