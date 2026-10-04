import '../../../../core/network/api_client.dart';
import '../../domain/entities/geo_point.dart';
import '../models/visit_model.dart';

/// Llamadas HTTP de `/visits`.
class VisitsRemoteDataSource {
  const VisitsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<VisitModel>> getVisits() async {
    final envelope = await _client.getJson('/visits');
    final data = envelope.data;
    if (data is! List) return const [];
    return data.cast<Map<String, dynamic>>().map(VisitModel.fromJson).toList();
  }

  Future<VisitModel> createVisit({
    required String name,
    required GeoPoint point,
    required DateTime date,
  }) async {
    final envelope = await _client.postJson('/visits', {
      'name': name,
      'latitude': point.latitude,
      'longitude': point.longitude,
      'date': VisitModel.formatApiDate(date),
    });
    return VisitModel.fromJson(envelope.dataObject);
  }

  Future<VisitModel> updateVisit(
    int id, {
    String? name,
    GeoPoint? point,
    DateTime? date,
  }) async {
    final envelope = await _client.patchJson('/visits/$id', {
      'name': ?name,
      if (point != null) ...{
        'latitude': point.latitude,
        'longitude': point.longitude,
      },
      if (date != null) 'date': VisitModel.formatApiDate(date),
    });
    return VisitModel.fromJson(envelope.dataObject);
  }

  Future<VisitModel> completeVisit(int id) async {
    final envelope = await _client.patchJson('/visits/$id/complete', const {});
    return VisitModel.fromJson(envelope.dataObject);
  }

  Future<VisitModel> cancelVisit(int id) async {
    final envelope = await _client.patchJson('/visits/$id/cancel', const {});
    return VisitModel.fromJson(envelope.dataObject);
  }

  Future<void> deleteVisit(int id) => _client.deleteJson('/visits/$id');
}
