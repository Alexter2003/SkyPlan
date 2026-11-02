import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/features/auth/presentation/screens/change_password_screen.dart';

import 'auth_test_app.dart';
import 'fake_auth_repository.dart';

Future<void> _fill(
  WidgetTester tester, {
  String current = 'Tmp9xKq2LmWz',
  String next = 'NewPassw0rd',
  String confirm = 'NewPassw0rd',
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), current);
  await tester.enterText(fields.at(1), next);
  await tester.enterText(fields.at(2), confirm);
  await tester.ensureVisible(find.text('Guardar contraseña'));
  await tester.tap(find.text('Guardar contraseña'));
  await tester.pumpAndSettle();
}

Future<FakeAuthRepository> _pump(WidgetTester tester) async {
  usePhoneViewport(tester);
  final repository = FakeAuthRepository();
  await tester.pumpWidget(
    buildAuthTestApp(
      repository: repository,
      child: const ChangePasswordScreen(),
    ),
  );
  return repository;
}

void main() {
  testWidgets('mismatched confirmation blocks the request', (tester) async {
    final repository = await _pump(tester);

    await _fill(tester, confirm: 'Different1');

    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(repository.lastPasswordChange, isNull);
  });

  testWidgets('a weak password blocks the request', (tester) async {
    final repository = await _pump(tester);

    await _fill(tester, next: 'short', confirm: 'short');

    expect(
      find.text('La contraseña debe tener entre 8 y 72 caracteres'),
      findsOneWidget,
    );
    expect(repository.lastPasswordChange, isNull);
  });

  testWidgets('success sends the three fields and goes home', (tester) async {
    final repository = await _pump(tester);

    await _fill(tester);

    expect(repository.lastPasswordChange?.current, 'Tmp9xKq2LmWz');
    expect(repository.lastPasswordChange?.next, 'NewPassw0rd');
    expect(repository.lastPasswordChange?.confirm, 'NewPassw0rd');
    expect(find.text('route:home'), findsOneWidget);
  });

  testWidgets('shows the API error and keeps the form', (tester) async {
    final repository = await _pump(tester);
    repository.changePasswordError = wrongCurrentPasswordError;

    await _fill(tester);

    expect(find.text('La contraseña actual es incorrecta'), findsOneWidget);
    expect(find.text('Guardar contraseña'), findsOneWidget);
    expect(find.text('route:home'), findsNothing);
  });

  testWidgets('an expired temporary password goes to forgot-password', (
    tester,
  ) async {
    final repository = await _pump(tester);
    repository.changePasswordError = expiredTemporaryPasswordError;

    await _fill(tester);

    expect(find.text('route:forgot-password'), findsOneWidget);
  });

  testWidgets('logout is available and leads to login', (tester) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('route:login'), findsOneWidget);
  });
}
