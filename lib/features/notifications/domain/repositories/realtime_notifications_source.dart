import '../entities/viability_notification.dart';

/// Canal en tiempo real (WebSocket) de avisos de viabilidad.
abstract class RealtimeNotificationsSource {
  Stream<ViabilityNotification> get notifications;

  void connect(String token);

  void disconnect();
}
