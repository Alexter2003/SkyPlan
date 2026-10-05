import '../repositories/activities_repository.dart';

class DeleteActivity {
  const DeleteActivity(this._repository);

  final ActivitiesRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
