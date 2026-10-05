import '../entities/visit_weather.dart';

/// Condiciones del catálogo (`sunny`, `clear`, `partly_cloudy`, `cloudy`,
/// `drizzle`, `rainy`, `snowy`, `windy`) que describen un pronóstico.
/// Mismas reglas que usa el backend para validar actividades.
Set<String> classifyWeather({
  required double cloudCover,
  required double precipitation,
  required double windSpeed,
  required int weatherCode,
}) {
  bool inRanges(int code, List<List<int>> ranges) =>
      ranges.any((r) => code >= r[0] && code <= r[1]);

  final result = <String>{};

  if (inRanges(weatherCode, [
    [71, 77],
    [85, 86],
  ])) {
    result.add('snowy');
  } else if (inRanges(weatherCode, [
        [61, 67],
        [80, 82],
        [95, 99],
      ]) ||
      precipitation >= 1) {
    result.add('rainy');
  } else if (inRanges(weatherCode, [
        [51, 57],
      ]) ||
      precipitation >= 0.1) {
    result.add('drizzle');
  }
  final hasPrecipitation = result.isNotEmpty;

  if (cloudCover >= 70) {
    result.add('cloudy');
  } else if (cloudCover >= 30) {
    result.add('partly_cloudy');
  } else if (!hasPrecipitation) {
    result
      ..add('sunny')
      ..add('clear');
  }
  if (windSpeed >= 30) result.add('windy');
  return result;
}

/// Clasifica un pronóstico; `null` si faltan datos (visitas anteriores a la
/// actualización del backend): no se debe adivinar el clima.
Set<String>? classifyVisitWeather(VisitWeather weather) {
  if (!weather.isClassifiable) return null;
  return classifyWeather(
    cloudCover: weather.cloudCover!,
    precipitation: weather.precipitation,
    windSpeed: weather.windSpeed!,
    weatherCode: weather.weatherCode!,
  );
}
