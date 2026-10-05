import '../../domain/entities/viability_notification.dart';

class ViabilityNotificationModel extends ViabilityNotification {
  const ViabilityNotificationModel({
    required super.id,
    required super.activityId,
    required super.visitId,
    required super.type,
    required super.title,
    required super.message,
    required super.createdAt,
  });

  /// Sirve para el objeto REST (`id`) y el evento del socket (`notificationId`).
  factory ViabilityNotificationModel.fromJson(Map<String, dynamic> json) {
    return ViabilityNotificationModel(
      id: (json['id'] ?? json['notificationId']) as int,
      activityId: json['activityId'] as int,
      visitId: json['visitId'] as int,
      type: json['type'] == 'ACTIVITY_VIABLE_AGAIN'
          ? ViabilityNotificationType.viableAgain
          : ViabilityNotificationType.notViable,
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
