import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/state/session_controller.dart';
import '../design_system/design_system.dart';
import '../routing/app_routes.dart';

/// Lleva al login (con aviso) cuando el servidor invalida la sesión.
class SessionExpiryListener extends StatefulWidget {
  const SessionExpiryListener({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<SessionExpiryListener> createState() => _SessionExpiryListenerState();
}

class _SessionExpiryListenerState extends State<SessionExpiryListener> {
  late final SessionController _session;

  @override
  void initState() {
    super.initState();
    _session = context.read<SessionController>()..addListener(_onChange);
  }

  @override
  void dispose() {
    _session.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (!_session.expired) return;
    _session.acknowledgeExpiry();
    final navigator = widget.navigatorKey.currentState;
    final navContext = widget.navigatorKey.currentContext;
    if (navigator == null || navContext == null) return;
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    SkySnackbar.show(
      navContext,
      'Tu sesión expiró, vuelve a iniciar sesión',
      tone: SkySnackbarTone.error,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
