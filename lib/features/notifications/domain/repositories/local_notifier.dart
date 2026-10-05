import '../entities/viability_notification.dart';

/// Notificaciones del sistema operativo.
abstract class LocalNotifier {
  /// Prepara el plugin y pide permiso al usuario.
  Future<void> init();

  Future<void> show(ViabilityNotification notification);

  /// Emite cuando el usuario toca una notificación.
  Stream<void> get taps;
}
