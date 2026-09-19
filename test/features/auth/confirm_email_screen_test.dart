import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/design_system.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/auth/presentation/screens/confirm_email_screen.dart';

import 'auth_test_app.dart';
import 'fake_auth_repository.dart';

void main() {
  testWidgets('starts the 60s resend cooldown immediately', (tester) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository();

    await tester.pumpWidget(
      buildAuthTestApp(
        repository: repository,
        child: const ConfirmEmailScreen(email: 'user@example.com'),
      ),
    );

    expect(find.textContaining('Podrás reenviar el código en'), findsOneWidget);
    expect(find.text('¿No te llegó? Reenviar código'), findsNothing);

    // Se desmonta antes de que termine el timer de 1 minuto.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the verify button stays disabled until the code is complete', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository();

    await tester.pumpWidget(
      buildAuthTestApp(
        repository: repository,
        child: const ConfirmEmailScreen(email: 'user@example.com'),
      ),
    );

    await tester.enterText(find.byType(TextField), 'ABC');
    await tester.pump();

    final button = tester.widget<SkyButton>(find.byType(SkyButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('navigates to login after tapping verify with a correct code', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final repository = FakeAuthRepository();

    await tester.pumpWidget(
      buildAuthTestApp(
        repository: repository,
        child: const ConfirmEmailScreen(email: 'user@example.com'),
      ),
    );

    await tester.enterText(find.byType(TextField), 'ABCDE');
    await tester.pump();
    await tester.tap(find.text('Verificar correo'));
    await tester.pumpAndSettle();

    expect(find.text('route:login'), findsOneWidget);
  });

  testWidgets('shows an error and clears the code on a rejected attempt', (
    tester,
  ) async {
    usePhoneViewport(tester);
    const invalidCodeError = ApiException(
      status: 400,
      message: 'Código de confirmación inválido o expirado',
    );
    final repository = FakeAuthRepository()
      ..confirmEmailError = invalidCodeError;

    await tester.pumpWidget(
      buildAuthTestApp(
        repository: repository,
        child: const ConfirmEmailScreen(email: 'user@example.com'),
      ),
    );

    await tester.enterText(find.byType(TextField), 'ABCDE');
    await tester.pump();
    await tester.tap(find.text('Verificar correo'));
    await tester.pumpAndSettle();

    expect(
      find.text('Código de confirmación inválido o expirado'),
      findsOneWidget,
    );
    expect(find.text('A'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
