/// `autoCancelled`: el sistema canceló la actividad por el clima; el usuario
/// puede reactivarla o reagendarla desde Pendientes.
enum ViabilityNotificationType { notViable, viableAgain, autoCancelled }

/// Aviso de que una actividad al aire libre dejó de ser viable (o volvió a serlo).
class ViabilityNotification {
  const ViabilityNotification({
    required this.id,
    required this.activityId,
    required this.visitId,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final int id;
  final int activityId;
  final int visitId;
  final ViabilityNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
}
