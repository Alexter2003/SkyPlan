import '../entities/geo_point.dart';
import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class CreateVisit {
  const CreateVisit(this._repository);

  final VisitsRepository _repository;

  Future<Visit> call({
    required String name,
    required GeoPoint point,
    required DateTime date,
  }) => _repository.createVisit(name: name, point: point, date: date);
}
