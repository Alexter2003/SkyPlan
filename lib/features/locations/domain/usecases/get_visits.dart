import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class GetVisits {
  const GetVisits(this._repository);

  final VisitsRepository _repository;

  Future<List<Visit>> call() => _repository.getVisits();
}
