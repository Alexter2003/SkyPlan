import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/entities/viability_notification.dart';
import '../../domain/repositories/local_notifier.dart';

/// Notificaciones del SO con `flutter_local_notifications`.
class FlutterLocalNotifier implements LocalNotifier {
  FlutterLocalNotifier() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _taps = StreamController<void>.broadcast();
  bool _initialized = false;

  static const _channel = AndroidNotificationDetails(
    'activity_viability',
    'Viabilidad de actividades',
    channelDescription:
        'Avisos cuando una actividad al aire libre deja de ser viable por el clima',
    importance: Importance.high,
    priority: Priority.high,
  );

  @override
  Stream<void> get taps => _taps.stream;

  @override
  Future<void> init() async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (_) => _taps.add(null),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  @override
  Future<void> show(ViabilityNotification notification) async {
    await init();
    await _plugin.show(
      id: notification.id,
      title: notification.title,
      body: notification.message,
      notificationDetails: const NotificationDetails(
        android: _channel,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
