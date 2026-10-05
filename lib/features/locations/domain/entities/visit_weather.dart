/// Pronóstico de las 12:00 del día de una visita.
class VisitWeather {
  const VisitWeather({
    required this.temperature,
    required this.precipitation,
    required this.humidity,
    required this.atmosphericPressure,
    required this.updatedAt,
    this.cloudCover,
    this.windSpeed,
    this.weatherCode,
  });

  /// °C.
  final double temperature;

  /// mm.
  final double precipitation;

  /// %. Solo informativa: no indica lluvia ni tipo de cielo.
  final double humidity;

  /// hPa.
  final double atmosphericPressure;
  final DateTime updatedAt;

  /// % de nubosidad. `null` en visitas anteriores a la actualización del backend.
  final double? cloudCover;

  /// km/h.
  final double? windSpeed;

  /// Código WMO; solo sirve para clasificar.
  final int? weatherCode;

  /// Hay datos suficientes para clasificar el clima.
  bool get isClassifiable =>
      cloudCover != null && windSpeed != null && weatherCode != null;
}
