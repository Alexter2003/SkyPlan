import '../../../locations/domain/entities/visit.dart';
import '../../../locations/domain/repositories/visits_repository.dart';
import '../entities/visit_activities.dart';
import '../repositories/activities_repository.dart';

/// Ubicaciones activas con sus actividades: planeadas primero, luego por fecha.
class GetActivitiesGroupedByVisit {
  const GetActivitiesGroupedByVisit(this._visits, this._activities);

  final VisitsRepository _visits;
  final ActivitiesRepository _activities;

  Future<List<VisitActivities>> call() async {
    final visits = await _visits.getVisits();
    final active = visits.where((v) => v.status != VisitStatus.cancelled);
    final groups = await Future.wait(
      active.map(
        (visit) async => VisitActivities(
          visit: visit,
          activities: await _activities.getByVisit(visit.id),
        ),
      ),
    );
    return groups..sort(_compare);
  }

  static int _compare(VisitActivities a, VisitActivities b) {
    final aPlanned = a.visit.status == VisitStatus.planned;
    final bPlanned = b.visit.status == VisitStatus.planned;
    if (aPlanned != bPlanned) return aPlanned ? -1 : 1;
    return a.visit.date.compareTo(b.visit.date);
  }
}
