import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/confirm_email_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../design_system/components/motion/sky_page_route.dart';

/// Argumentos para la ruta de confirmación de correo.
class ConfirmEmailArgs {
  const ConfirmEmailArgs({required this.email});
  final String email;
}

/// Rutas nombradas de la app.
abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const confirmEmail = '/confirm-email';
  static const home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return SkyPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case register:
        return SkyPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case confirmEmail:
        final args = settings.arguments as ConfirmEmailArgs;
        return SkyPageRoute(
          settings: settings,
          builder: (_) => ConfirmEmailScreen(email: args.email),
        );
      case home:
        return SkyPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      default:
        return SkyPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no encontrada: ${settings.name}')),
          ),
        );
    }
  }
}
