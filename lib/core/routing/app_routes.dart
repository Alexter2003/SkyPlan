import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/confirm_email_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/locations/domain/entities/geo_point.dart';
import '../../features/locations/domain/entities/visit.dart';
import '../../features/locations/presentation/screens/location_form_screen.dart';
import '../../features/locations/presentation/screens/locations_screen.dart';
import '../../features/locations/presentation/screens/map_picker_screen.dart';
import '../design_system/components/motion/sky_page_route.dart';

/// Argumentos para la ruta de confirmación de correo.
class ConfirmEmailArgs {
  const ConfirmEmailArgs({required this.email});
  final String email;
}

/// Argumentos del formulario de ubicación; `visit` nulo = crear.
class LocationFormArgs {
  const LocationFormArgs({this.visit});
  final Visit? visit;
}

/// Argumentos del selector de mapa.
class MapPickerArgs {
  const MapPickerArgs({this.initial});
  final GeoPoint? initial;
}

/// Rutas nombradas de la app.
abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const confirmEmail = '/confirm-email';
  static const home = '/home';
  static const locations = '/locations';
  static const locationForm = '/locations/form';
  static const mapPicker = '/locations/map';

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
      case locations:
        return SkyPageRoute(
          settings: settings,
          builder: (_) => const LocationsScreen(),
        );
      case locationForm:
        final args = settings.arguments as LocationFormArgs?;
        return SkyPageRoute<Visit>(
          settings: settings,
          builder: (_) => LocationFormScreen(visit: args?.visit),
        );
      case mapPicker:
        final args = settings.arguments as MapPickerArgs?;
        return SkyPageRoute<GeoPoint>(
          settings: settings,
          builder: (_) => MapPickerScreen(initial: args?.initial),
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
