import '../../../../core/network/api_client.dart';
import '../models/viability_notification_model.dart';

/// Llamadas HTTP de `/notifications`.
class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<ViabilityNotificationModel>> fetchUnread() async {
    final envelope = await _client.getJson('/notifications?unread=true');
    final data = envelope.data;
    if (data is! List) return const [];
    return data
        .cast<Map<String, dynamic>>()
        .map(ViabilityNotificationModel.fromJson)
        .toList();
  }

  Future<void> markRead(int id) =>
      _client.patchJson('/notifications/$id/read', const {});
}
