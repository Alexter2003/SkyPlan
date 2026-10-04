import '../entities/geo_point.dart';
import '../entities/visit.dart';

/// Contrato de ubicaciones registradas (visitas).
abstract class VisitsRepository {
  Future<List<Visit>> getVisits();

  Future<Visit> createVisit({
    required String name,
    required GeoPoint point,
    required DateTime date,
  });

  /// Solo se envían los campos no nulos.
  Future<Visit> updateVisit(
    int id, {
    String? name,
    GeoPoint? point,
    DateTime? date,
  });

  Future<Visit> completeVisit(int id);

  Future<Visit> cancelVisit(int id);

  Future<void> deleteVisit(int id);
}
