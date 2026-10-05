import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/visit_weather.dart';
import '../../domain/services/weather_classifier.dart';
import 'weather_descriptions.dart';

/// Pronóstico de una ubicación en lenguaje cotidiano: la temperatura y cómo
/// será el día (lluvia, cielo, viento), sin cifras técnicas.
///
/// Sin datos o con datos incompletos muestra "Clima pendiente": nunca un
/// clima por defecto.
class VisitWeatherPanel extends StatelessWidget {
  const VisitWeatherPanel({super.key, required this.weather});

  final VisitWeather? weather;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final data = weather;

    if (data == null) return const SkyBadge(label: 'Clima pendiente');

    final conditions = classifyVisitWeather(data);
    final primary = conditions == null ? null : primaryCondition(conditions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SkyIcon(
              primary == null ? SkyIconType.cloud : weatherIcon(primary),
              size: 28,
              color: colors.primaryBlue,
            ),
            const SizedBox(width: SkySpacing.xs),
            Text('${data.temperature.round()} °C', style: typography.headline),
            const SizedBox(width: SkySpacing.xs),
            Text(
              temperatureFeel(data.temperature),
              style: typography.body.copyWith(color: colors.subtle),
            ),
          ],
        ),
        const SizedBox(height: SkySpacing.xs),
        if (conditions == null)
          const SkyBadge(label: 'Clima pendiente')
        else
          Wrap(
            spacing: SkySpacing.xs,
            runSpacing: SkySpacing.xs,
            children: [
              _Fact(
                icon: conditions.contains('snowy')
                    ? SkyIconType.snow
                    : SkyIconType.rain,
                text: precipitationText(data.precipitation, conditions),
              ),
              _Fact(
                icon: cloudIcon(data.cloudCover!),
                text: cloudText(data.cloudCover!),
              ),
              _Fact(icon: SkyIconType.wind, text: windText(data.windSpeed!)),
            ],
          ),
      ],
    );
  }
}

/// Versión compacta: temperatura y condiciones como insignias.
class VisitWeatherSummary extends StatelessWidget {
  const VisitWeatherSummary({super.key, required this.weather});

  final VisitWeather? weather;

  @override
  Widget build(BuildContext context) {
    final data = weather;
    final conditions = data == null ? null : classifyVisitWeather(data);

    return Wrap(
      spacing: SkySpacing.xs,
      runSpacing: SkySpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (data != null) SkyBadge(label: '${data.temperature.round()} °C'),
        if (conditions == null)
          const SkyBadge(label: 'Clima pendiente')
        else
          for (final c in displayConditions(conditions))
            _ConditionBadge(condition: c),
      ],
    );
  }
}

class _ConditionBadge extends StatelessWidget {
  const _ConditionBadge({required this.condition});

  final String condition;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final isWind = condition == 'windy';
    final background = isWind ? colors.primaryYellow : colors.primaryBlue;
    final foreground = isWind ? colors.ink : colors.onAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkyIcon(weatherIcon(condition), size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            weatherLabel(condition),
            style: typography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final SkyIconType icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkyIcon(icon, size: 16, color: colors.subtle),
        const SizedBox(width: SkySpacing.xxs),
        Text(text, style: typography.caption),
      ],
    );
  }
}
