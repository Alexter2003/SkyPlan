import '../entities/activity_action_result.dart';
import '../repositories/activities_repository.dart';

class UncompleteActivity {
  const UncompleteActivity(this._repository);

  final ActivitiesRepository _repository;

  Future<ActivityActionResult> call(int id) => _repository.uncomplete(id);
}
