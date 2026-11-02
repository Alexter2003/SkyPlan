import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sky_plan/core/navigation/password_change_listener.dart';
import 'package:sky_plan/core/storage/session_storage.dart';
import 'package:sky_plan/features/auth/domain/usecases/change_password.dart';
import 'package:sky_plan/features/auth/domain/usecases/get_account_profile.dart';
import 'package:sky_plan/features/auth/domain/usecases/logout.dart';
import 'package:sky_plan/features/auth/presentation/screens/auth_gate.dart';
import 'package:sky_plan/features/auth/presentation/state/session_controller.dart';

import '../../features/auth/auth_test_app.dart';
import '../../features/auth/fake_auth_repository.dart';

Future<SessionController> _pumpApp(
  WidgetTester tester,
  FakeAuthRepository repository,
  InMemorySessionStorage storage,
) async {
  usePhoneViewport(tester);
  final navigatorKey = GlobalKey<NavigatorState>();
  final session = SessionController(
    storage: storage,
    logout: Logout(repository),
    getProfile: GetAccountProfile(repository),
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider.value(value: ChangePassword(repository)),
        ChangeNotifierProvider.value(value: session),
      ],
      child: PasswordChangeListener(
        navigatorKey: navigatorKey,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: '/home',
          routes: {
            '/home': (_) => const Scaffold(body: Text('home')),
            '/change-password': (_) =>
                const Scaffold(body: Text('route:change-password')),
          },
        ),
      ),
    ),
  );
  return session;
}

void main() {
  testWidgets('a mid-session pending-change 403 redirects', (tester) async {
    final repository = FakeAuthRepository();
    final session = await _pumpApp(
      tester,
      repository,
      InMemorySessionStorage(),
    );
    await session.establish(
      await repository.login(identifier: 'a', password: 'b'),
    );
    await tester.pumpAndSettle();
    expect(find.text('route:change-password'), findsNothing);

    session.requirePasswordChange();
    await tester.pumpAndSettle();

    expect(find.text('route:change-password'), findsOneWidget);
  });

  testWidgets('login with a temporary password redirects', (tester) async {
    final repository = FakeAuthRepository()..loginRequiresPasswordChange = true;
    final session = await _pumpApp(
      tester,
      repository,
      InMemorySessionStorage(),
    );

    await session.establish(
      await repository.login(identifier: 'a', password: 'b'),
    );
    await tester.pumpAndSettle();

    expect(find.text('route:change-password'), findsOneWidget);
  });

  testWidgets('restart with a pending change shows change-password', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository()
      ..profileRequiresPasswordChange = true;
    final storage = InMemorySessionStorage();
    await storage.save(
      StoredSession(
        token: 'tok',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        username: 'user123',
        email: 'user@example.com',
      ),
    );

    await tester.pumpWidget(
      buildAuthTestApp(
        repository: repository,
        storage: storage,
        child: const AuthGate(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Elige tu contraseña'), findsOneWidget);
  });
}
