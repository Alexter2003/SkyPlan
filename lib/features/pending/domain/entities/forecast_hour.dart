/// Clima proyectado de una hora de la franja de una actividad.
class ForecastHour {
  const ForecastHour({
    required this.time,
    required this.weatherCode,
    required this.precipitation,
    required this.cloudCover,
    required this.windSpeed,
    required this.precipitationProbability,
  });

  /// Hora local de la ubicación, `YYYY-MM-DDTHH:00` (sin zona).
  final String time;

  /// Código WMO (0 despejado, 61 lluvia, ...).
  final int weatherCode;

  /// mm.
  final double precipitation;

  /// %.
  final int cloudCover;

  /// km/h.
  final double windSpeed;

  /// %.
  final int precipitationProbability;

  /// `HH:mm` de la hora proyectada.
  String get hourLabel => time.length >= 16 ? time.substring(11, 16) : time;
}
