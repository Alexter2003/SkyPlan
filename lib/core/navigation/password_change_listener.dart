import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/state/session_controller.dart';
import '../routing/app_routes.dart';

/// Lleva a la pantalla de cambio de contraseña, sin salida, cuando el
/// servidor exige cambiar la temporal (login, reinicio o un 403 a mitad de
/// sesión).
class PasswordChangeListener extends StatefulWidget {
  const PasswordChangeListener({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<PasswordChangeListener> createState() => _PasswordChangeListenerState();
}

class _PasswordChangeListenerState extends State<PasswordChangeListener> {
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
    if (_session.status != SessionStatus.passwordChangeRequired) return;
    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) return;

    String? current;
    navigator.popUntil((route) {
      current = route.settings.name;
      return true;
    });
    // La raíz ("/") es AuthGate, que ya muestra la pantalla de cambio.
    if (current == AppRoutes.changePassword || current == '/') return;
    navigator.pushNamedAndRemoveUntil(AppRoutes.changePassword, (_) => false);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
