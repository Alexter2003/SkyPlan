import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme_context.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/auth/domain/entities/auth_user.dart';
import 'package:sky_plan/features/auth/domain/repositories/auth_repository.dart';
import 'package:sky_plan/features/auth/domain/usecases/get_account_profile.dart';
import 'package:sky_plan/features/auth/domain/usecases/logout.dart';
import 'package:sky_plan/features/auth/presentation/state/session_controller.dart';
import 'package:sky_plan/features/profile/domain/repositories/profile_repository.dart';
import 'package:sky_plan/features/profile/domain/usecases/update_profile.dart';
import 'package:sky_plan/features/profile/presentation/screens/profile_screen.dart';

import '../auth/auth_test_app.dart';
import '../auth/fake_auth_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  Object? error;
  final calls = <({String? firstName, String? lastName})>[];

  @override
  Future<AuthUser> update({String? firstName, String? lastName}) async {
    calls.add((firstName: firstName, lastName: lastName));
    if (error != null) throw error!;
    return AuthUser(
      id: 1,
      email: 'user@example.com',
      username: 'user123',
      emailConfirmed: true,
      createdAt: DateTime(2026, 1, 1),
      firstName: firstName ?? 'Ana',
      lastName: lastName,
    );
  }
}

Future<SessionController> _pump(
  WidgetTester tester, {
  required FakeAuthRepository auth,
  required FakeProfileRepository profile,
}) async {
  usePhoneViewport(tester);
  final session = SessionController(
    storage: InMemorySessionStorage(),
    logout: Logout(auth),
  );
  await tester.pumpWidget(
    SkyThemeScope(
      controller: SkyThemeController(),
      child: MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: auth),
          Provider<GetAccountProfile>(create: (c) => GetAccountProfile(auth)),
          Provider<ProfileRepository>.value(value: profile),
          Provider<UpdateProfile>(create: (_) => UpdateProfile(profile)),
          ChangeNotifierProvider<SessionController>.value(value: session),
        ],
        child: MaterialApp(theme: SkyTheme.light, home: const ProfileScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return session;
}

void main() {
  testWidgets('shows username and email read-only, with no password field', (
    tester,
  ) async {
    await _pump(
      tester,
      auth: FakeAuthRepository(),
      profile: FakeProfileRepository(),
    );

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    // username, email (disabled) + first/last name (enabled)
    expect(fields.length, 4);
    expect(fields[0].enabled, isFalse);
    expect(fields[1].enabled, isFalse);
    expect(fields[2].enabled, isTrue);
    expect(fields[3].enabled, isTrue);
    expect(find.text('user123'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('Contraseña'), findsNothing);
  });

  testWidgets('editing only the first name sends only firstName', (
    tester,
  ) async {
    final profile = FakeProfileRepository();
    final session = await _pump(
      tester,
      auth: FakeAuthRepository(),
      profile: profile,
    );
    await session.establish(
      await FakeAuthRepository().login(identifier: 'a', password: 'b'),
    );

    await tester.enterText(find.byType(TextFormField).at(2), 'Ana');
    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(profile.calls.single, (firstName: 'Ana', lastName: null));
    expect(find.text('Perfil actualizado'), findsOneWidget);
    expect(session.session?.user.firstName, 'Ana');
  });

  testWidgets('saving without changes does not send a request', (tester) async {
    final profile = FakeProfileRepository();
    await _pump(tester, auth: FakeAuthRepository(), profile: profile);

    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(profile.calls, isEmpty);
  });

  testWidgets('a name longer than 100 characters shows a field error', (
    tester,
  ) async {
    final profile = FakeProfileRepository();
    await _pump(tester, auth: FakeAuthRepository(), profile: profile);

    await tester.enterText(find.byType(TextFormField).at(2), 'a' * 101);
    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(
      find.text('El nombre no puede exceder 100 caracteres'),
      findsOneWidget,
    );
    expect(profile.calls, isEmpty);
  });

  testWidgets('shows the API error and keeps the typed input', (tester) async {
    final profile = FakeProfileRepository()
      ..error = const ApiException(
        status: 403,
        message: 'Tu cuenta está inactiva',
      );
    await _pump(tester, auth: FakeAuthRepository(), profile: profile);

    await tester.enterText(find.byType(TextFormField).at(2), 'Ana');
    await tester.ensureVisible(find.text('Guardar cambios'));
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.text('Tu cuenta está inactiva'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
  });

  testWidgets('a load failure shows the message and a retry action', (
    tester,
  ) async {
    final auth = FakeAuthRepository()..profileError = const NetworkException();
    await _pump(tester, auth: auth, profile: FakeProfileRepository());

    expect(find.text('Reintentar'), findsOneWidget);

    auth.profileError = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('user123'), findsOneWidget);
  });
}
