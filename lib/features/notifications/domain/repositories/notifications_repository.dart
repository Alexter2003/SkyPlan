import '../entities/viability_notification.dart';

/// Bandeja de avisos (REST) para recuperar lo ocurrido con la app cerrada.
abstract class NotificationsRepository {
  Future<List<ViabilityNotification>> fetchUnread();

  Future<void> markRead(int id);
}
