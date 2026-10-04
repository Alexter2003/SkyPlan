import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class CompleteVisit {
  const CompleteVisit(this._repository);

  final VisitsRepository _repository;

  Future<Visit> call(int id) => _repository.completeVisit(id);
}
