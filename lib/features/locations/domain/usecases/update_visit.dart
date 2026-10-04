import '../entities/geo_point.dart';
import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class UpdateVisit {
  const UpdateVisit(this._repository);

  final VisitsRepository _repository;

  Future<Visit> call(int id, {String? name, GeoPoint? point, DateTime? date}) {
    return _repository.updateVisit(id, name: name, point: point, date: date);
  }
}
