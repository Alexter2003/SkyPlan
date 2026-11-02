import '../entities/activity.dart';
import '../entities/time_of_day_value.dart';
import '../repositories/activities_repository.dart';

class RescheduleActivity {
  const RescheduleActivity(this._repository);

  final ActivitiesRepository _repository;

  Future<Activity> call(
    int id, {
    required DateTime date,
    required TimeOfDayValue startTime,
    required TimeOfDayValue endTime,
  }) => _repository.reschedule(
    id,
    date: date,
    startTime: startTime,
    endTime: endTime,
  );
}
