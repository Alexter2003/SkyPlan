import '../../domain/entities/activity.dart';
import '../../domain/entities/time_of_day_value.dart';
import '../../domain/repositories/activities_repository.dart';
import '../datasources/activities_remote_datasource.dart';

class ActivitiesRepositoryImpl implements ActivitiesRepository {
  const ActivitiesRepositoryImpl(this._remote);

  final ActivitiesRemoteDataSource _remote;

  @override
  Future<List<Activity>> getByVisit(int visitId) => _remote.getByVisit(visitId);

  @override
  Future<Activity> create({
    required int visitId,
    required String name,
    required String description,
    required TimeOfDayValue startTime,
    required TimeOfDayValue endTime,
    required ActivityType type,
    required List<int> weatherConditionIds,
  }) => _remote.create(
    visitId: visitId,
    name: name,
    description: description,
    startTime: startTime,
    endTime: endTime,
    type: type,
    weatherConditionIds: weatherConditionIds,
  );

  @override
  Future<Activity> update(
    int id, {
    String? name,
    String? description,
    TimeOfDayValue? startTime,
    TimeOfDayValue? endTime,
    ActivityType? type,
    List<int>? weatherConditionIds,
  }) => _remote.update(
    id,
    name: name,
    description: description,
    startTime: startTime,
    endTime: endTime,
    type: type,
    weatherConditionIds: weatherConditionIds,
  );

  @override
  Future<void> delete(int id) => _remote.delete(id);
}
