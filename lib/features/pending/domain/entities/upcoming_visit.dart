import '../../../locations/domain/entities/visit.dart';

/// Ubicación de una actividad próxima, tal como la devuelve `/upcoming`.
class UpcomingVisit {
  const UpcomingVisit({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.status,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final DateTime date;
  final VisitStatus status;

  UpcomingVisit withStatus(VisitStatus value) => UpcomingVisit(
    id: id,
    name: name,
    latitude: latitude,
    longitude: longitude,
    date: date,
    status: value,
  );
}
