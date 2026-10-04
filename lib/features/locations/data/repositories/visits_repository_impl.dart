import '../../domain/entities/geo_point.dart';
import '../../domain/entities/visit.dart';
import '../../domain/repositories/visits_repository.dart';
import '../datasources/visits_remote_datasource.dart';

class VisitsRepositoryImpl implements VisitsRepository {
  const VisitsRepositoryImpl(this._remote);

  final VisitsRemoteDataSource _remote;

  @override
  Future<List<Visit>> getVisits() => _remote.getVisits();

  @override
  Future<Visit> createVisit({
    required String name,
    required GeoPoint point,
    required DateTime date,
  }) => _remote.createVisit(name: name, point: point, date: date);

  @override
  Future<Visit> updateVisit(
    int id, {
    String? name,
    GeoPoint? point,
    DateTime? date,
  }) => _remote.updateVisit(id, name: name, point: point, date: date);

  @override
  Future<Visit> completeVisit(int id) => _remote.completeVisit(id);

  @override
  Future<Visit> cancelVisit(int id) => _remote.cancelVisit(id);

  @override
  Future<void> deleteVisit(int id) => _remote.deleteVisit(id);
}
