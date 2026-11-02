import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';
import 'package:sky_plan/core/storage/session_storage.dart';
import 'package:sky_plan/features/auth/domain/repositories/auth_repository.dart';
import 'package:sky_plan/features/auth/domain/usecases/change_password.dart';
import 'package:sky_plan/features/auth/domain/usecases/confirm_email.dart';
import 'package:sky_plan/features/auth/domain/usecases/forgot_password.dart';
import 'package:sky_plan/features/auth/domain/usecases/get_account_profile.dart';
import 'package:sky_plan/features/auth/domain/usecases/login.dart';
import 'package:sky_plan/features/auth/domain/usecases/logout.dart';
import 'package:sky_plan/features/auth/domain/usecases/register_user.dart';
import 'package:sky_plan/features/auth/domain/usecases/resend_confirmation.dart';
import 'package:sky_plan/features/auth/presentation/state/session_controller.dart';

/// Storage en memoria, sin depender del secure storage real.
class InMemorySessionStorage implements SessionStorage {
  StoredSession? _stored;

  @override
  Future<void> save(StoredSession session) async => _stored = session;

  @override
  Future<StoredSession?> read() async => _stored;

  @override
  Future<void> clear() async => _stored = null;
}

/// Simula el viewport de un teléfono real.
void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// App de prueba con los providers y rutas de una pantalla de auth.
Widget buildAuthTestApp({
  required AuthRepository repository,
  required Widget child,
  String initialRoute = '/',
  SessionStorage? storage,
}) {
  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: repository),
      Provider<RegisterUser>(create: (c) => RegisterUser(c.read())),
      Provider<ConfirmEmail>(create: (c) => ConfirmEmail(c.read())),
      Provider<ResendConfirmation>(create: (c) => ResendConfirmation(c.read())),
      Provider<Login>(create: (c) => Login(c.read())),
      Provider<Logout>(create: (c) => Logout(c.read())),
      Provider<ForgotPassword>(create: (c) => ForgotPassword(c.read())),
      Provider<ChangePassword>(create: (c) => ChangePassword(c.read())),
      Provider<GetAccountProfile>(create: (c) => GetAccountProfile(c.read())),
      ChangeNotifierProvider<SessionController>(
        create: (c) => SessionController(
          storage: storage ?? InMemorySessionStorage(),
          logout: c.read(),
          getProfile: c.read(),
        ),
      ),
    ],
    child: MaterialApp(
      theme: SkyTheme.light,
      initialRoute: initialRoute,
      routes: {
        '/': (_) => child,
        '/login': (_) => const _RouteMarker('login'),
        '/register': (_) => const _RouteMarker('register'),
        '/home': (_) => const _RouteMarker('home'),
        '/forgot-password': (_) => const _RouteMarker('forgot-password'),
        '/change-password': (_) => const _RouteMarker('change-password'),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/confirm-email') {
          return MaterialPageRoute(
            builder: (_) => const _RouteMarker('confirm-email'),
          );
        }
        return null;
      },
    ),
  );
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker(this.name);
  final String name;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text('route:$name'));
}
