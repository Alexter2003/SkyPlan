import '../entities/activity.dart';
import '../repositories/activities_repository.dart';

class GetActivitiesByVisit {
  const GetActivitiesByVisit(this._repository);

  final ActivitiesRepository _repository;

  Future<List<Activity>> call(int visitId) => _repository.getByVisit(visitId);
}
