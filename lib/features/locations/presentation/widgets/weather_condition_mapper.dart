import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/visit_weather.dart';

/// Resume el pronóstico en una condición visual para `SkyWeatherChip`.
SkyWeatherCondition conditionFor(VisitWeather weather) {
  if (weather.precipitation >= 1) return SkyWeatherCondition.rainy;
  if (weather.humidity >= 80) return SkyWeatherCondition.cloudy;
  return SkyWeatherCondition.sunny;
}
