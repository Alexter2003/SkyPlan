import '../../../../core/network/api_client.dart';
import '../../../activities/domain/entities/activity.dart';
import '../../domain/entities/upcoming_filters.dart';
import '../../domain/entities/upcoming_page.dart';
import '../models/upcoming_activity_model.dart';

/// Llamada HTTP de `GET /activities/upcoming`.
class UpcomingRemoteDataSource {
  const UpcomingRemoteDataSource(this._client);

  final ApiClient _client;

  /// Query string con solo los criterios activos; todos se combinan.
  static Map<String, String> query(UpcomingFilters f) => {
    if (f.days != null) 'days': '${f.days}',
    if (f.visitId != null) 'visitId': '${f.visitId}',
    if (f.probabilityMin != null) 'probabilityMin': '${f.probabilityMin}',
    if (f.probabilityMax != null) 'probabilityMax': '${f.probabilityMax}',
    if (f.state != null) 'state': stateToApi(f.state!),
    'sortBy': f.sortBy == UpcomingSort.probability ? 'probability' : 'date',
    'order': f.ascending ? 'asc' : 'desc',
    'limit': '${f.limit}',
  };

  static String stateToApi(ActivityState state) => switch (state) {
    ActivityState.planned => 'planned',
    ActivityState.completed => 'completed',
    ActivityState.cancelled => 'cancelled',
    ActivityState.cancelledBySystem => 'cancelled_by_system',
  };

  Future<UpcomingPage> getUpcoming(UpcomingFilters filters) async {
    final path = Uri(
      path: '/activities/upcoming',
      queryParameters: query(filters),
    ).toString();
    final envelope = await _client.getJson(path);
    return UpcomingModels.page(envelope.dataObject);
  }
}
