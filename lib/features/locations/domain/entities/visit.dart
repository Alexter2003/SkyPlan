import 'geo_point.dart';
import 'visit_weather.dart';

enum VisitStatus { planned, completed, cancelled }

/// Ubicación registrada por el usuario para una fecha (en la API: visita).
class Visit {
  const Visit({
    required this.id,
    required this.name,
    required this.point,
    required this.date,
    required this.status,
    required this.createdAt,
    this.weather,
  });

  final int id;
  final String name;
  final GeoPoint point;

  /// Solo fecha (sin hora).
  final DateTime date;
  final VisitStatus status;
  final DateTime createdAt;

  /// `null` mientras la fecha esté a más de 10 días.
  final VisitWeather? weather;

  /// Solo una visita planeada puede editarse o cambiar de estado.
  bool get isEditable => status == VisitStatus.planned;

  bool get canCancel => status == VisitStatus.planned;

  /// Solo se finaliza una visita planeada cuya fecha ya llegó.
  bool canComplete(DateTime today) {
    if (status != VisitStatus.planned) return false;
    final day = DateTime(today.year, today.month, today.day);
    return !date.isAfter(day);
  }
}
