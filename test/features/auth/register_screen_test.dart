import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/features/auth/presentation/screens/register_screen.dart';

import 'auth_test_app.dart';
import 'fake_auth_repository.dart';

void main() {
  Future<void> fillForm(
    WidgetTester tester, {
    String email = 'user@example.com',
    String username = 'user123',
    String password = 'Sky2026plan',
    String? confirmation,
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), username);
    await tester.enterText(find.byType(TextFormField).at(2), password);
    await tester.enterText(
      find.byType(TextFormField).at(3),
      confirmation ?? password,
    );
  }

  testWidgets('shows a validation error without calling the API', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository();

    await tester.pumpWidget(
      buildAuthTestApp(repository: repository, child: const RegisterScreen()),
    );

    await tester.tap(find.text('Crear cuenta'));
    await tester.pump();

    expect(find.text('El correo es obligatorio'), findsOneWidget);
  });

  testWidgets('shows the API error banner on a duplicate email (409)', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository()
      ..registerError = duplicateEmailError;

    await tester.pumpWidget(
      buildAuthTestApp(repository: repository, child: const RegisterScreen()),
    );

    await fillForm(tester);
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ya existe un usuario registrado con ese correo'),
      findsOneWidget,
    );
  });

  testWidgets('navigates to email confirmation on success', (tester) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository();

    await tester.pumpWidget(
      buildAuthTestApp(repository: repository, child: const RegisterScreen()),
    );

    await fillForm(tester);
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('route:confirm-email'), findsOneWidget);
  });
}
