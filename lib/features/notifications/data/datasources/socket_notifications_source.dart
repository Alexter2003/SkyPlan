import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/config/app_config.dart';
import '../../domain/entities/viability_notification.dart';
import '../../domain/repositories/realtime_notifications_source.dart';
import '../models/viability_notification_model.dart';

/// Cliente socket.io del namespace `/notifications`.
class SocketNotificationsSource implements RealtimeNotificationsSource {
  static const _event = 'activity.viability_changed';

  final _controller = StreamController<ViabilityNotification>.broadcast();
  io.Socket? _socket;

  @override
  Stream<ViabilityNotification> get notifications => _controller.stream;

  @override
  void connect(String token) {
    disconnect();
    final socket = io.io(
      '${AppConfig.socketBaseUrl}/notifications',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );
    socket.on(_event, (data) {
      if (data is! Map) return;
      try {
        _controller.add(
          ViabilityNotificationModel.fromJson(Map<String, dynamic>.from(data)),
        );
      } catch (_) {
        // Evento mal formado: se ignora; el aviso queda en la bandeja REST.
      }
    });
    socket.connect();
    _socket = socket;
  }

  @override
  void disconnect() {
    _socket
      ?..dispose()
      ..disconnect();
    _socket = null;
  }
}
