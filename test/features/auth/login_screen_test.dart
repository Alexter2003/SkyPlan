import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/features/auth/presentation/screens/login_screen.dart';

import 'auth_test_app.dart';
import 'fake_auth_repository.dart';

void main() {
  testWidgets('shows "Credenciales inválidas" on a 401', (tester) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository()
      ..loginError = invalidCredentialsError;

    await tester.pumpWidget(
      buildAuthTestApp(repository: repository, child: const LoginScreen()),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-password');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Credenciales inválidas'), findsOneWidget);
  });

  testWidgets(
    'offers "Confirmar ahora" and navigates to confirm-email on a 403 unconfirmed error',
    (tester) async {
      usePhoneViewport(tester);
      final repository = FakeAuthRepository()
        ..loginError = unconfirmedEmailError;

      await tester.pumpWidget(
        buildAuthTestApp(repository: repository, child: const LoginScreen()),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Sky2026plan');
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar ahora'), findsOneWidget);

      await tester.tap(find.text('Confirmar ahora'));
      await tester.pumpAndSettle();

      expect(find.text('route:confirm-email'), findsOneWidget);
    },
  );

  testWidgets('navigates to home on success', (tester) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository();

    await tester.pumpWidget(
      buildAuthTestApp(repository: repository, child: const LoginScreen()),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Sky2026plan');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('route:home'), findsOneWidget);
  });
}
