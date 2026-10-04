/// Pronóstico del día de una visita.
class VisitWeather {
  const VisitWeather({
    required this.temperature,
    required this.precipitation,
    required this.humidity,
    required this.atmosphericPressure,
    required this.updatedAt,
  });

  /// °C.
  final double temperature;

  /// mm.
  final double precipitation;

  /// %.
  final double humidity;

  /// hPa.
  final double atmosphericPressure;
  final DateTime updatedAt;
}
