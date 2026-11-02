import '../entities/activity_action_result.dart';
import '../repositories/activities_repository.dart';

class CancelActivity {
  const CancelActivity(this._repository);

  final ActivitiesRepository _repository;

  /// [reason] vacío se trata como ausente.
  Future<ActivityActionResult> call(int id, {String? reason}) {
    final trimmed = reason?.trim();
    return _repository.cancel(
      id,
      reason: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
  }
}
