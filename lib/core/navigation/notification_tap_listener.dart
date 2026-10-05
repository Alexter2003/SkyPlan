import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/notifications/presentation/state/notifications_controller.dart';
import '../routing/app_routes.dart';

/// Lleva a Actividades cuando el usuario toca una notificación del SO y
/// recupera los avisos pendientes al volver la app a primer plano.
class NotificationTapListener extends StatefulWidget {
  const NotificationTapListener({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<NotificationTapListener> createState() =>
      _NotificationTapListenerState();
}

class _NotificationTapListenerState extends State<NotificationTapListener>
    with WidgetsBindingObserver {
  late final NotificationsController _controller;
  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = context.read<NotificationsController>();
    _sub = _controller.opened.listen((_) => _open());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _controller.fetchPending();
  }

  void _open() {
    widget.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.activities,
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
