import '../entities/activity_action_result.dart';
import '../repositories/activities_repository.dart';

class CompleteActivity {
  const CompleteActivity(this._repository);

  final ActivitiesRepository _repository;

  Future<ActivityActionResult> call(int id) => _repository.complete(id);
}
