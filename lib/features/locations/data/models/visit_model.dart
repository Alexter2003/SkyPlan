import '../../domain/entities/geo_point.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_weather.dart';

class VisitModel extends Visit {
  const VisitModel({
    required super.id,
    required super.name,
    required super.point,
    required super.date,
    required super.status,
    required super.createdAt,
    super.weather,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'] as int,
      name: json['name'] as String,
      point: GeoPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      ),
      date: parseApiDate(json['date'] as String),
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      weather: _parseWeather(json),
    );
  }

  /// `YYYY-MM-DD` → fecha local sin hora.
  static DateTime parseApiDate(String value) {
    final parts = value.split('T').first.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  /// Fecha local → `YYYY-MM-DD`.
  static String formatApiDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  static VisitStatus _parseStatus(String value) => switch (value) {
    'COMPLETED' => VisitStatus.completed,
    'CANCELLED' => VisitStatus.cancelled,
    _ => VisitStatus.planned,
  };

  // Los campos de clima vienen null juntos (fecha a más de 10 días).
  static VisitWeather? _parseWeather(Map<String, dynamic> json) {
    final temperature = json['temperature'];
    final updatedAt = json['weatherUpdate'];
    if (temperature == null || updatedAt == null) return null;
    return VisitWeather(
      temperature: (temperature as num).toDouble(),
      precipitation: (json['precipitation'] as num? ?? 0).toDouble(),
      humidity: (json['humidity'] as num? ?? 0).toDouble(),
      atmosphericPressure: (json['atmosphericPressure'] as num? ?? 0)
          .toDouble(),
      updatedAt: DateTime.parse(updatedAt as String),
      cloudCover: (json['cloudCover'] as num?)?.toDouble(),
      windSpeed: (json['windSpeed'] as num?)?.toDouble(),
      weatherCode: (json['weatherCode'] as num?)?.toInt(),
    );
  }
}
