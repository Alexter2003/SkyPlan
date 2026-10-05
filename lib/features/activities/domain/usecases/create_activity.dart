import '../entities/activity.dart';
import '../entities/time_of_day_value.dart';
import '../repositories/activities_repository.dart';

class CreateActivity {
  const CreateActivity(this._repository);

  final ActivitiesRepository _repository;

  Future<Activity> call({
    required int visitId,
    required String name,
    required String description,
    required TimeOfDayValue startTime,
    required TimeOfDayValue endTime,
    required ActivityType type,
    required List<int> weatherConditionIds,
  }) => _repository.create(
    visitId: visitId,
    name: name,
    description: description,
    startTime: startTime,
    endTime: endTime,
    type: type,
    weatherConditionIds: weatherConditionIds,
  );
}
