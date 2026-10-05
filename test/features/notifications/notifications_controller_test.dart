import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/features/auth/domain/entities/auth_user.dart';
import 'package:sky_plan/features/auth/domain/entities/session.dart';
import 'package:sky_plan/features/auth/domain/usecases/logout.dart';
import 'package:sky_plan/features/auth/presentation/state/session_controller.dart';
import 'package:sky_plan/features/notifications/data/models/viability_notification_model.dart';
import 'package:sky_plan/features/notifications/domain/entities/viability_notification.dart';
import 'package:sky_plan/features/notifications/presentation/state/notifications_controller.dart';

import '../auth/auth_test_app.dart';
import '../auth/fake_auth_repository.dart';
import 'notifications_test_support.dart';

Session _session(String token) => Session(
  token: token,
  expiresAt: DateTime(2030),
  mustChangePassword: false,
  user: AuthUser(
    id: 1,
    email: 'a@b.c',
    username: 'user',
    emailConfirmed: true,
    createdAt: DateTime(2026),
  ),
);

class _Setup {
  _Setup() {
    session = SessionController(
      storage: InMemorySessionStorage(),
      logout: Logout(FakeAuthRepository()),
    );
    controller = NotificationsController(
      session: session,
      repository: repo,
      realtime: realtime,
      notifier: notifier,
    );
  }

  final repo = FakeNotificationsRepository();
  final realtime = FakeRealtimeSource();
  final notifier = FakeLocalNotifier();
  late final SessionController session;
  late final NotificationsController controller;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test(
    'connects the socket when a session starts and disconnects on logout',
    () async {
      final s = _Setup()..controller.start();
      expect(s.realtime.connectedTokens, isEmpty);

      await s.session.establish(_session('tok-1'));
      await _settle();
      expect(s.realtime.connectedTokens, ['tok-1']);
      expect(s.notifier.inits, 1);

      final disconnectsBefore = s.realtime.disconnects;
      await s.session.endSession();
      await _settle();
      expect(s.realtime.disconnects, greaterThan(disconnectsBefore));
    },
  );

  test(
    'a socket event shows a local notification, marks it read and bumps revision',
    () async {
      final s = _Setup()..controller.start();
      await s.session.establish(_session('tok'));
      await _settle();

      s.realtime.emit(makeNotification(id: 9));
      await _settle();

      expect(s.notifier.shown.single.id, 9);
      expect(s.repo.read, [9]);
      expect(s.controller.revision, 1);
    },
  );

  test('the same notification from socket and REST is shown once', () async {
    final s = _Setup()..controller.start();
    s.repo.unread = [makeNotification(id: 3)];
    await s.session.establish(_session('tok'));
    await _settle();

    s.realtime.emit(makeNotification(id: 3));
    await _settle();

    expect(s.notifier.shown, hasLength(1));
  });

  test('fetchPending shows unread notifications oldest first', () async {
    final s = _Setup()..controller.start();
    s.repo.unread = [makeNotification(id: 2), makeNotification(id: 1)];
    await s.session.establish(_session('tok'));
    await _settle();

    expect(s.notifier.shown.map((n) => n.id), [1, 2]);
  });

  test('a failing REST fetch does not break the controller', () async {
    final s = _Setup()..controller.start();
    s.repo.error = Exception('offline');
    await s.session.establish(_session('tok'));
    await _settle();

    expect(s.notifier.shown, isEmpty);
    expect(s.controller.revision, 0);
  });

  test('tapping a notification emits opened', () async {
    final s = _Setup()..controller.start();
    final opened = expectLater(s.controller.opened, emits(anything));

    s.notifier.tap();
    await opened;
  });

  test('parses socket and REST payloads', () {
    final fromSocket = ViabilityNotificationModel.fromJson({
      'notificationId': 9,
      'activityId': 5,
      'visitId': 10,
      'type': 'ACTIVITY_VIABLE_AGAIN',
      'title': 't',
      'message': 'm',
      'createdAt': '2026-10-04T18:00:00.000Z',
    });
    final fromRest = ViabilityNotificationModel.fromJson({
      'id': 9,
      'activityId': 5,
      'visitId': 10,
      'type': 'ACTIVITY_NOT_VIABLE',
      'title': 't',
      'message': 'm',
      'readAt': null,
      'createdAt': '2026-10-04T18:00:00.000Z',
    });

    expect(fromSocket.id, 9);
    expect(fromSocket.type, ViabilityNotificationType.viableAgain);
    expect(fromRest.id, 9);
    expect(fromRest.type, ViabilityNotificationType.notViable);
  });
}
