import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sky_plan/core/navigation/notification_tap_listener.dart';
import 'package:sky_plan/features/auth/domain/usecases/logout.dart';
import 'package:sky_plan/features/auth/presentation/state/session_controller.dart';
import 'package:sky_plan/features/notifications/presentation/state/notifications_controller.dart';

import '../../features/auth/auth_test_app.dart';
import '../../features/auth/fake_auth_repository.dart';
import '../../features/notifications/notifications_test_support.dart';

void main() {
  testWidgets('tapping an OS notification opens Pendientes', (tester) async {
    final notifier = FakeLocalNotifier();
    final navigatorKey = GlobalKey<NavigatorState>();
    final controller = NotificationsController(
      session: SessionController(
        storage: InMemorySessionStorage(),
        logout: Logout(FakeAuthRepository()),
      ),
      repository: FakeNotificationsRepository(),
      realtime: FakeRealtimeSource(),
      notifier: notifier,
    )..start();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: NotificationTapListener(
          navigatorKey: navigatorKey,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: Text('home')),
            routes: {
              '/pending': (_) => const Scaffold(body: Text('route:pending')),
            },
          ),
        ),
      ),
    );

    notifier.tap();
    await tester.pumpAndSettle();

    expect(find.text('route:pending'), findsOneWidget);
  });
}
