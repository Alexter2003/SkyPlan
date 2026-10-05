import 'dart:async';

import 'package:sky_plan/features/notifications/domain/entities/viability_notification.dart';
import 'package:sky_plan/features/notifications/domain/repositories/local_notifier.dart';
import 'package:sky_plan/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:sky_plan/features/notifications/domain/repositories/realtime_notifications_source.dart';

ViabilityNotification makeNotification({
  int id = 1,
  ViabilityNotificationType type = ViabilityNotificationType.notViable,
}) {
  return ViabilityNotification(
    id: id,
    activityId: 5,
    visitId: 10,
    type: type,
    title: 'Actividad no viable',
    message: "La actividad 'Caminata' ya no es viable",
    createdAt: DateTime(2026, 10, 4),
  );
}

class FakeNotificationsRepository implements NotificationsRepository {
  List<ViabilityNotification> unread = [];
  Object? error;
  final List<int> read = [];

  @override
  Future<List<ViabilityNotification>> fetchUnread() async {
    if (error != null) throw error!;
    return [...unread];
  }

  @override
  Future<void> markRead(int id) async => read.add(id);
}

class FakeRealtimeSource implements RealtimeNotificationsSource {
  final _controller = StreamController<ViabilityNotification>.broadcast();
  final List<String> connectedTokens = [];
  int disconnects = 0;

  void emit(ViabilityNotification n) => _controller.add(n);

  @override
  Stream<ViabilityNotification> get notifications => _controller.stream;

  @override
  void connect(String token) => connectedTokens.add(token);

  @override
  void disconnect() => disconnects++;
}

class FakeLocalNotifier implements LocalNotifier {
  final _taps = StreamController<void>.broadcast();
  final List<ViabilityNotification> shown = [];
  int inits = 0;

  void tap() => _taps.add(null);

  @override
  Future<void> init() async => inits++;

  @override
  Future<void> show(ViabilityNotification notification) async =>
      shown.add(notification);

  @override
  Stream<void> get taps => _taps.stream;
}
