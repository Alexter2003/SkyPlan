import '../entities/activity.dart';
import '../repositories/activities_repository.dart';

class ReactivateActivity {
  const ReactivateActivity(this._repository);

  final ActivitiesRepository _repository;

  Future<Activity> call(int id) => _repository.reactivate(id);
}
