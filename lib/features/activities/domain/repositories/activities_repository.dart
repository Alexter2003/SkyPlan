import '../entities/activity.dart';
import '../entities/time_of_day_value.dart';

/// Contrato de actividades.
abstract class ActivitiesRepository {
  Future<List<Activity>> getByVisit(int visitId);

  Future<Activity> create({
    required int visitId,
    required String name,
    required String description,
    required TimeOfDayValue startTime,
    required TimeOfDayValue endTime,
    required ActivityType type,
    required List<int> weatherConditionIds,
  });

  /// Solo se envían los campos no nulos.
  Future<Activity> update(
    int id, {
    String? name,
    String? description,
    TimeOfDayValue? startTime,
    TimeOfDayValue? endTime,
    ActivityType? type,
    List<int>? weatherConditionIds,
  });

  Future<void> delete(int id);
}
