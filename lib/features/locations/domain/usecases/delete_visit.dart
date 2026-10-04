import '../repositories/visits_repository.dart';

/// Elimina la ubicación; el backend elimina también sus actividades.
class DeleteVisit {
  const DeleteVisit(this._repository);

  final VisitsRepository _repository;

  Future<void> call(int id) => _repository.deleteVisit(id);
}
