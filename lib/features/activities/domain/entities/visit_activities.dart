import '../../../locations/domain/entities/visit.dart';
import 'activity.dart';

/// Una ubicación junto con sus actividades.
class VisitActivities {
  const VisitActivities({required this.visit, required this.activities});

  final Visit visit;
  final List<Activity> activities;
}
