import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../state/session_controller.dart';
import 'login_screen.dart';

/// Decide entre Home o Login según haya sesión guardada.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<SessionController>().bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<SessionController>().status;

    return switch (status) {
      SessionStatus.unknown => const _SplashLoader(),
      SessionStatus.authenticated => const HomeScreen(),
      SessionStatus.unauthenticated => const LoginScreen(),
    };
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return SkyScaffold(
      showGrid: false,
      body: Center(
        child: SkyFadeSlideIn(
          child: const SkyLogo(showTagline: true, markSize: 64),
        ),
      ),
    );
  }
}
