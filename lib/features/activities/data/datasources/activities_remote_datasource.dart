import '../../../../core/network/api_client.dart';
import '../../../locations/data/models/visit_model.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/activity_action_result.dart';
import '../../domain/entities/time_of_day_value.dart';
import '../models/activity_model.dart';

/// Llamadas HTTP de `/activities`.
class ActivitiesRemoteDataSource {
  const ActivitiesRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<ActivityModel>> getByVisit(int visitId) async {
    final envelope = await _client.getJson('/activities?visitId=$visitId');
    final data = envelope.data;
    if (data is! List) return const [];
    return data
        .cast<Map<String, dynamic>>()
        .map(ActivityModel.fromJson)
        .toList();
  }

  Future<ActivityModel> create({
    required int visitId,
    required String name,
    required String description,
    required TimeOfDayValue startTime,
    required TimeOfDayValue endTime,
    required ActivityType type,
    required List<int> weatherConditionIds,
  }) async {
    final envelope = await _client.postJson('/activities', {
      'visitId': visitId,
      'name': name,
      'description': description,
      'startTime': startTime.format(),
      'endTime': endTime.format(),
      'type': ActivityModel.typeToApi(type),
      'weatherConditionIds': weatherConditionIds,
    });
    return ActivityModel.fromJson(envelope.dataObject);
  }

  Future<ActivityModel> update(
    int id, {
    String? name,
    String? description,
    TimeOfDayValue? startTime,
    TimeOfDayValue? endTime,
    ActivityType? type,
    List<int>? weatherConditionIds,
  }) async {
    final envelope = await _client.patchJson('/activities/$id', {
      'name': ?name,
      'description': ?description,
      if (startTime != null) 'startTime': startTime.format(),
      if (endTime != null) 'endTime': endTime.format(),
      if (type != null) 'type': ActivityModel.typeToApi(type),
      'weatherConditionIds': ?weatherConditionIds,
    });
    return ActivityModel.fromJson(envelope.dataObject);
  }

  Future<void> delete(int id) => _client.deleteJson('/activities/$id');

  Future<ActivityActionResult> complete(int id) =>
      _action('/activities/$id/complete', const {});

  Future<ActivityActionResult> uncomplete(int id) =>
      _action('/activities/$id/uncomplete', const {});

  Future<ActivityActionResult> cancel(int id, {String? reason}) =>
      _action('/activities/$id/cancel', {'reason': ?reason});

  Future<ActivityModel> reactivate(int id) async {
    final envelope = await _client.patchJson(
      '/activities/$id/reactivate',
      const {},
    );
    return ActivityModel.fromJson(envelope.dataObject);
  }

  Future<ActivityModel> reschedule(
    int id, {
    required DateTime date,
    required TimeOfDayValue startTime,
    required TimeOfDayValue endTime,
  }) async {
    final envelope = await _client.patchJson('/activities/$id/reschedule', {
      'date': VisitModel.formatApiDate(date),
      'startTime': startTime.format(),
      'endTime': endTime.format(),
    });
    return ActivityModel.fromJson(envelope.dataObject);
  }

  Future<ActivityActionResult> _action(
    String path,
    Map<String, dynamic> body,
  ) async {
    final envelope = await _client.patchJson(path, body);
    final data = envelope.dataObject;
    final visitStatus = data['visitStatus'];
    return ActivityActionResult(
      activity: ActivityModel.fromJson(data),
      visitStatus: visitStatus is String
          ? VisitModel.parseStatus(visitStatus)
          : null,
    );
  }
}
