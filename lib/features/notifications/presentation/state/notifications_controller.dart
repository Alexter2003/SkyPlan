// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../auth/presentation/state/session_controller.dart';
import '../../domain/entities/viability_notification.dart';
import '../../domain/repositories/local_notifier.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/repositories/realtime_notifications_source.dart';

/// Une el socket, la bandeja REST y las notificaciones del SO.
///
/// Con sesión activa abre el socket y recupera lo no leído; al cerrar o
/// expirar la sesión lo desconecta. Cada aviso nuevo se muestra una sola vez
/// (aunque llegue por socket y por REST), se marca leído y sube [revision]
/// para que las pantallas de actividades se refresquen.
class NotificationsController extends ChangeNotifier {
  NotificationsController({
    required SessionController session,
    required NotificationsRepository repository,
    required RealtimeNotificationsSource realtime,
    required LocalNotifier notifier,
  }) : _session = session,
       _repository = repository,
       _realtime = realtime,
       _notifier = notifier;

  final SessionController _session;
  final NotificationsRepository _repository;
  final RealtimeNotificationsSource _realtime;
  final LocalNotifier _notifier;

  final _seen = <int>{};
  final _opened = StreamController<void>.broadcast();
  StreamSubscription<ViabilityNotification>? _realtimeSub;
  StreamSubscription<void>? _tapSub;
  String? _connectedToken;

  /// Sube con cada aviso recibido.
  int revision = 0;

  /// Emite cuando el usuario abre una notificación del SO.
  Stream<void> get opened => _opened.stream;

  void start() {
    _session.addListener(_onSessionChanged);
    _tapSub = _notifier.taps.listen((_) => _opened.add(null));
    _realtimeSub = _realtime.notifications.listen(_handle);
    _onSessionChanged();
  }

  void _onSessionChanged() {
    final token = _session.status == SessionStatus.authenticated
        ? _session.session?.token
        : null;
    if (token == _connectedToken) return;
    _connectedToken = token;

    if (token == null) {
      _realtime.disconnect();
      _seen.clear();
      return;
    }
    unawaited(_notifier.init().catchError((_) {}));
    _realtime.connect(token);
    unawaited(fetchPending());
  }

  /// Recupera lo que llegó con la app cerrada o en segundo plano.
  Future<void> fetchPending() async {
    if (_connectedToken == null) return;
    try {
      final pending = await _repository.fetchUnread();
      for (final notification in pending.reversed) {
        await _handle(notification);
      }
    } catch (_) {
      // Sin red: se reintenta al volver a primer plano.
    }
  }

  Future<void> _handle(ViabilityNotification notification) async {
    if (!_seen.add(notification.id)) return;
    revision++;
    notifyListeners();
    try {
      await _notifier.show(notification);
    } catch (_) {
      // Sin permiso de notificaciones: la lista igual se refresca.
    }
    try {
      await _repository.markRead(notification.id);
    } catch (_) {
      // Se reintentará con el siguiente fetch; _seen evita repetirla ahora.
    }
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    _realtimeSub?.cancel();
    _tapSub?.cancel();
    _opened.close();
    _realtime.disconnect();
    super.dispose();
  }
}
