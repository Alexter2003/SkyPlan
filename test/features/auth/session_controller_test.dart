import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/core/storage/session_storage.dart';
import 'package:sky_plan/features/auth/domain/usecases/get_account_profile.dart';
import 'package:sky_plan/features/auth/domain/usecases/logout.dart';
import 'package:sky_plan/features/auth/presentation/state/session_controller.dart';

import 'auth_test_app.dart';
import 'fake_auth_repository.dart';

StoredSession _stored() => StoredSession(
  token: 'tok',
  expiresAt: DateTime.now().add(const Duration(days: 1)),
  username: 'user123',
  email: 'user@example.com',
);

void main() {
  late FakeAuthRepository repository;
  late InMemorySessionStorage storage;
  late StreamController<void> passwordChange;

  SessionController build() => SessionController(
    storage: storage,
    logout: Logout(repository),
    getProfile: GetAccountProfile(repository),
    passwordChangeRequired: passwordChange.stream,
  );

  setUp(() {
    repository = FakeAuthRepository();
    storage = InMemorySessionStorage();
    passwordChange = StreamController<void>.broadcast();
  });

  tearDown(() => passwordChange.close());

  test('establish with a temporary password requires a change', () async {
    repository.loginRequiresPasswordChange = true;
    final controller = build();

    await controller.establish(
      await repository.login(identifier: 'a', password: 'b'),
    );

    expect(controller.status, SessionStatus.passwordChangeRequired);
  });

  test('establish with a normal login is authenticated', () async {
    final controller = build();

    await controller.establish(
      await repository.login(identifier: 'a', password: 'b'),
    );

    expect(controller.status, SessionStatus.authenticated);
  });

  test('the pending-change stream blocks an authenticated session', () async {
    final controller = build();
    await controller.establish(
      await repository.login(identifier: 'a', password: 'b'),
    );

    passwordChange.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(controller.status, SessionStatus.passwordChangeRequired);
    expect(controller.session!.mustChangePassword, isTrue);
  });

  test('completePasswordChange keeps the token and unlocks the app', () async {
    repository.loginRequiresPasswordChange = true;
    final controller = build();
    await controller.establish(
      await repository.login(identifier: 'a', password: 'b'),
    );

    controller.completePasswordChange();

    expect(controller.status, SessionStatus.authenticated);
    expect(controller.session!.token, 'fake-token');
    expect(controller.session!.mustChangePassword, isFalse);
  });

  group('bootstrap', () {
    test(
      'with a pending change the profile sends to change-password',
      () async {
        await storage.save(_stored());
        repository.profileRequiresPasswordChange = true;
        final controller = build();

        await controller.bootstrap();

        expect(controller.status, SessionStatus.passwordChangeRequired);
      },
    );

    test('with a normal profile stays authenticated', () async {
      await storage.save(_stored());
      final controller = build();

      await controller.bootstrap();

      expect(controller.status, SessionStatus.authenticated);
      expect(repository.getProfileCalls, 1);
    });

    test('a network failure keeps the stored session', () async {
      await storage.save(_stored());
      repository.profileError = const NetworkException();
      final controller = build();

      await controller.bootstrap();

      expect(controller.status, SessionStatus.authenticated);
      expect(controller.session!.user.username, 'user123');
    });

    test('a 401 ends the session', () async {
      await storage.save(_stored());
      repository.profileError = const ApiException(
        status: 401,
        message: 'No autenticado',
      );
      final controller = build();

      await controller.bootstrap();

      expect(controller.status, SessionStatus.unauthenticated);
      expect(await storage.read(), isNull);
    });

    test('without stored session it is unauthenticated', () async {
      final controller = build();

      await controller.bootstrap();

      expect(controller.status, SessionStatus.unauthenticated);
      expect(repository.getProfileCalls, 0);
    });
  });
}
