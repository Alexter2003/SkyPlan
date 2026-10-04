import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class CancelVisit {
  const CancelVisit(this._repository);

  final VisitsRepository _repository;

  Future<Visit> call(int id) => _repository.cancelVisit(id);
}
