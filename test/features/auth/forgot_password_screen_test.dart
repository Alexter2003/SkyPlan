import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/auth/presentation/screens/forgot_password_screen.dart';

import 'auth_test_app.dart';
import 'fake_auth_repository.dart';

const _neutral =
    'Si el correo está registrado, recibirás una contraseña temporal.';

void main() {
  testWidgets('a malformed email shows a field error and sends nothing', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository();
    await tester.pumpWidget(
      buildAuthTestApp(
        repository: repository,
        child: const ForgotPasswordScreen(),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'not-an-email');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un correo válido'), findsOneWidget);
    expect(repository.lastForgotPasswordEmail, isNull);
  });

  testWidgets('a valid email shows the neutral message', (tester) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository();
    await tester.pumpWidget(
      buildAuthTestApp(
        repository: repository,
        child: const ForgotPasswordScreen(),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(repository.lastForgotPasswordEmail, 'user@example.com');
    expect(find.text(_neutral), findsOneWidget);
  });

  testWidgets('shows the API error message', (tester) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository()
      ..forgotPasswordError = const ApiException(
        status: 400,
        message: 'email must be an email',
      );
    await tester.pumpWidget(
      buildAuthTestApp(
        repository: repository,
        child: const ForgotPasswordScreen(),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('email must be an email'), findsOneWidget);
    expect(find.text(_neutral), findsNothing);
  });

  testWidgets('prefills the email and shows a previous notice', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildAuthTestApp(
        repository: FakeAuthRepository(),
        child: const ForgotPasswordScreen(
          email: 'user@example.com',
          notice: 'La contraseña temporal expiró',
        ),
      ),
    );

    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('La contraseña temporal expiró'), findsOneWidget);
  });
}
