import 'package:flutter/material.dart';

import '../../features/activities/domain/entities/activity.dart';
import '../../features/activities/presentation/screens/activities_screen.dart';
import '../../features/activities/presentation/screens/activity_form_screen.dart';
import '../../features/activities/presentation/screens/visit_activities_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/confirm_email_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/locations/domain/entities/geo_point.dart';
import '../../features/locations/domain/entities/visit.dart';
import '../../features/locations/presentation/screens/location_form_screen.dart';
import '../../features/locations/presentation/screens/locations_screen.dart';
import '../../features/locations/presentation/screens/map_picker_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../design_system/components/motion/sky_page_route.dart';

/// Argumentos para la ruta de confirmación de correo.
class ConfirmEmailArgs {
  const ConfirmEmailArgs({required this.email});
  final String email;
}

/// Argumentos de "olvidé mi contraseña".
class ForgotPasswordArgs {
  const ForgotPasswordArgs({this.email = '', this.notice});
  final String email;
  final String? notice;
}

/// Argumentos del formulario de ubicación; `visit` nulo = crear.
class LocationFormArgs {
  const LocationFormArgs({this.visit});
  final Visit? visit;
}

/// Argumentos del formulario de actividad; `activity` nulo = crear.
class ActivityFormArgs {
  const ActivityFormArgs({this.activity, this.visit});
  final Activity? activity;
  final Visit? visit;
}

/// Argumentos del detalle de actividades de una ubicación.
class VisitActivitiesArgs {
  const VisitActivitiesArgs({required this.visit});
  final Visit visit;
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
  static const forgotPassword = '/forgot-password';
  static const changePassword = '/change-password';
  static const home = '/home';
  static const profile = '/profile';
  static const locations = '/locations';
  static const locationForm = '/locations/form';
  static const mapPicker = '/locations/map';
  static const activities = '/activities';
  static const activityForm = '/activities/form';
  static const visitActivities = '/locations/activities';

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
      case forgotPassword:
        final args = settings.arguments as ForgotPasswordArgs?;
        return SkyPageRoute(
          settings: settings,
          builder: (_) => ForgotPasswordScreen(
            email: args?.email ?? '',
            notice: args?.notice,
          ),
        );
      case changePassword:
        return SkyPageRoute(
          settings: settings,
          builder: (_) => const ChangePasswordScreen(),
        );
      case home:
        return SkyPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case profile:
        return SkyPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(),
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
      case activities:
        return SkyPageRoute(
          settings: settings,
          builder: (_) => const ActivitiesScreen(),
        );
      case activityForm:
        final args = settings.arguments as ActivityFormArgs?;
        return SkyPageRoute<Activity>(
          settings: settings,
          builder: (_) =>
              ActivityFormScreen(activity: args?.activity, visit: args?.visit),
        );
      case visitActivities:
        final args = settings.arguments as VisitActivitiesArgs;
        return SkyPageRoute(
          settings: settings,
          builder: (_) => VisitActivitiesScreen(visit: args.visit),
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
