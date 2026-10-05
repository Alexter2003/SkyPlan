import '../entities/activity.dart';
import '../entities/time_of_day_value.dart';
import '../repositories/activities_repository.dart';

class UpdateActivity {
  const UpdateActivity(this._repository);

  final ActivitiesRepository _repository;

  Future<Activity> call(
    int id, {
    String? name,
    String? description,
    TimeOfDayValue? startTime,
    TimeOfDayValue? endTime,
    ActivityType? type,
    List<int>? weatherConditionIds,
  }) => _repository.update(
    id,
    name: name,
    description: description,
    startTime: startTime,
    endTime: endTime,
    type: type,
    weatherConditionIds: weatherConditionIds,
  );
}
