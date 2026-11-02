import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';
import 'package:sky_plan/features/auth/domain/usecases/logout.dart';
import 'package:sky_plan/features/auth/presentation/state/session_controller.dart';
import 'package:sky_plan/features/notifications/presentation/state/notifications_controller.dart';
import 'package:sky_plan/features/pending/domain/entities/forecast_hour.dart';
import 'package:sky_plan/features/pending/domain/entities/upcoming_activity.dart';
import 'package:sky_plan/features/pending/presentation/screens/pending_activities_screen.dart';

import '../activities/activities_test_support.dart';
import '../auth/auth_test_app.dart';
import '../auth/fake_auth_repository.dart';
import '../notifications/notifications_test_support.dart';
import 'pending_test_support.dart';

void tallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<({FakeUpcomingRepository upcoming, FakeActivitiesRepository activities})>
_pump(
  WidgetTester tester, {
  List<UpcomingActivity>? items,
  NotificationsController? notifications,
}) async {
  tallViewport(tester);
  final list = items ?? [makeUpcoming(id: 1)];
  final upcoming = FakeUpcomingRepository(list);
  final activities = FakeActivitiesRepository([
    for (final i in list) i.activity,
  ]);
  await tester.pumpWidget(
    buildPendingTestApp(
      upcoming: upcoming,
      activities: activities,
      notifications: notifications,
      child: const PendingActivitiesScreen(),
    ),
  );
  await tester.pumpAndSettle();
  return (upcoming: upcoming, activities: activities);
}

Future<void> _openMenu(WidgetTester tester, {int index = 0}) async {
  await tester.tap(find.byTooltip('Opciones').at(index));
  await tester.pumpAndSettle();
}

void main() {
  group('listing', () {
    testWidgets('shows location, forecast, state and probability', (
      tester,
    ) async {
      await _pump(
        tester,
        items: [
          UpcomingActivity(
            activity: makeActivity(
              id: 1,
              name: 'Caminata',
              probability: 80,
              band: ProbabilityBand.green,
            ),
            visit: makeUpcomingVisit(name: 'Antigua Guatemala'),
            forecast: const [
              ForecastHour(
                time: '2030-01-10T09:00',
                weatherCode: 0,
                precipitation: 0,
                cloudCover: 5,
                windSpeed: 5,
                precipitationProbability: 10,
              ),
            ],
          ),
        ],
      );

      expect(find.text('Caminata'), findsOneWidget);
      expect(find.text('Antigua Guatemala'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.text('80% · Alta'), findsOneWidget);
      expect(find.byKey(const ValueKey('forecast-summary')), findsOneWidget);
      expect(find.textContaining('10% de lluvia'), findsOneWidget);
    });

    testWidgets('the four states are visually distinct', (tester) async {
      await _pump(
        tester,
        items: [
          makeUpcoming(id: 1, name: 'A'),
          makeUpcoming(id: 2, name: 'B', state: ActivityState.completed),
          makeUpcoming(id: 3, name: 'C', state: ActivityState.cancelled),
          makeUpcoming(
            id: 4,
            name: 'D',
            state: ActivityState.cancelledBySystem,
            probability: 10,
            band: ProbabilityBand.red,
            cancelReason:
                'Cancelada automáticamente: la probabilidad bajó a 10%',
          ),
        ],
      );

      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.text('Completada'), findsOneWidget);
      expect(find.text('Cancelada por ti'), findsOneWidget);
      expect(find.text('Cancelada por el clima'), findsOneWidget);
      expect(find.textContaining('Cancelada automáticamente'), findsOneWidget);
    });

    testWidgets('null probability shows "Pendiente de validar"', (
      tester,
    ) async {
      await _pump(tester, items: [makeUpcoming(probability: null, band: null)]);

      expect(find.text('Pendiente de validar'), findsOneWidget);
      expect(find.text('Clima pendiente de pronóstico'), findsOneWidget);
    });

    testWidgets('shows an empty state', (tester) async {
      await _pump(tester, items: const []);

      expect(find.text('No tienes actividades próximas'), findsOneWidget);
    });

    testWidgets('shows the API error with a retry that recovers', (
      tester,
    ) async {
      tallViewport(tester);
      final upcoming = FakeUpcomingRepository([makeUpcoming()])
        ..error = const NetworkException();
      await tester.pumpWidget(
        buildPendingTestApp(
          upcoming: upcoming,
          activities: FakeActivitiesRepository(),
          child: const PendingActivitiesScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reintentar'), findsOneWidget);

      upcoming.error = null;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Caminata'), findsOneWidget);
    });
  });

  group('refresh', () {
    testWidgets('loads on enter and again on pull-to-refresh', (tester) async {
      final repos = await _pump(tester);
      expect(repos.upcoming.requests, hasLength(1));

      await tester.drag(find.byType(ListView), const Offset(0, 1200));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(repos.upcoming.requests.length, greaterThan(1));
    });

    testWidgets('a notification refreshes the list silently', (tester) async {
      final realtime = FakeRealtimeSource();
      late NotificationsController notifications;
      notifications = NotificationsController(
        session: SessionController(
          storage: InMemorySessionStorage(),
          logout: Logout(FakeAuthRepository()),
        ),
        repository: FakeNotificationsRepository(),
        realtime: realtime,
        notifier: FakeLocalNotifier(),
      )..start();
      final repos = await _pump(tester, notifications: notifications);
      final before = repos.upcoming.requests.length;

      realtime.emit(makeNotification(id: 7));
      await tester.pumpAndSettle();

      expect(repos.upcoming.requests.length, before + 1);
    });
  });

  group('checklist', () {
    testWidgets('the checkbox completes the activity', (tester) async {
      final repos = await _pump(tester);

      await tester.tap(find.byKey(const ValueKey('complete-checkbox')));
      await tester.pumpAndSettle();

      expect(repos.activities.actions, ['complete:1']);
      expect(find.text('Completada'), findsOneWidget);
    });

    testWidgets('cancelled activities have no checkbox', (tester) async {
      await _pump(
        tester,
        items: [makeUpcoming(state: ActivityState.cancelledBySystem)],
      );

      expect(find.byKey(const ValueKey('complete-checkbox')), findsNothing);
    });

    testWidgets('an API refusal reverts the checkbox and shows the message', (
      tester,
    ) async {
      final repos = await _pump(tester);
      repos.activities.error = const ApiException(
        status: 400,
        message: 'No puedes finalizar una visita cuya fecha aún no ha llegado',
      );

      await tester.tap(find.byKey(const ValueKey('complete-checkbox')));
      await tester.pumpAndSettle();

      expect(find.text('Pendiente'), findsOneWidget);
      expect(
        find.text(
          'No puedes finalizar una visita cuya fecha aún no ha llegado',
        ),
        findsOneWidget,
      );
    });
  });

  group('cancel', () {
    testWidgets('asks for confirmation and sends the reason', (tester) async {
      final repos = await _pump(tester);

      await _openMenu(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Me enfermé');
      await tester.tap(find.text('Cancelar actividad'));
      await tester.pumpAndSettle();

      expect(repos.activities.actions, ['cancel:1:Me enfermé']);
      expect(find.text('Cancelada por ti'), findsOneWidget);
    });

    testWidgets('dismissing the confirmation sends nothing', (tester) async {
      final repos = await _pump(tester);

      await _openMenu(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();

      expect(repos.activities.actions, isEmpty);
    });

    testWidgets('a completed activity offers no menu actions', (tester) async {
      await _pump(
        tester,
        items: [makeUpcoming(state: ActivityState.completed)],
      );

      await _openMenu(tester);

      expect(find.text('Cancelar'), findsNothing);
      expect(find.text('Reagendar'), findsNothing);
    });
  });

  group('reactivate', () {
    testWidgets('a red band asks before reactivating', (tester) async {
      final repos = await _pump(
        tester,
        items: [
          makeUpcoming(
            state: ActivityState.cancelledBySystem,
            probability: 10,
            band: ProbabilityBand.red,
          ),
        ],
      );

      await _openMenu(tester);
      await tester.tap(find.text('Reactivar'));
      await tester.pumpAndSettle();
      expect(find.text('El clima sigue mal'), findsOneWidget);
      expect(repos.activities.actions, isEmpty);

      await tester.tap(find.text('Reactivar'));
      await tester.pumpAndSettle();

      expect(repos.activities.actions, ['reactivate:1']);
      expect(find.text('Pendiente'), findsOneWidget);
    });

    testWidgets('a schedule conflict offers to reschedule', (tester) async {
      final repos = await _pump(
        tester,
        items: [
          makeUpcoming(
            state: ActivityState.cancelled,
            probability: 80,
            band: ProbabilityBand.green,
          ),
        ],
      );
      repos.activities.error = const ApiException(
        status: 409,
        message:
            "El horario se cruza con la actividad 'Almuerzo' (15:00–17:00)",
      );

      await _openMenu(tester);
      await tester.tap(find.text('Reactivar'));
      await tester.pumpAndSettle();

      expect(find.text('No se pudo reactivar'), findsOneWidget);
      expect(find.textContaining('Almuerzo'), findsOneWidget);
      expect(find.text('Reagendar'), findsOneWidget);
    });
  });

  group('reschedule', () {
    testWidgets('submits the new schedule and refreshes', (tester) async {
      final repos = await _pump(tester);

      await _openMenu(tester);
      await tester.tap(find.text('Reagendar'));
      await tester.pumpAndSettle();
      final before = repos.upcoming.requests.length;
      await tester.tap(find.text('Reagendar'));
      await tester.pumpAndSettle();

      expect(repos.activities.rescheduled, hasLength(1));
      expect(repos.upcoming.requests.length, before + 1);
      expect(find.text('Actividad reagendada'), findsOneWidget);
    });

    testWidgets('a 422 forecast message is shown verbatim, sheet stays', (
      tester,
    ) async {
      final repos = await _pump(tester);
      repos.activities.error = const ApiException(
        status: 422,
        message:
            'No se puede guardar la actividad: para el 2030-01-12 el '
            'pronóstico indica lluvia, incompatible con: soleado',
      );

      await _openMenu(tester);
      await tester.tap(find.text('Reagendar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reagendar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('incompatible con: soleado'), findsOneWidget);
      expect(find.text('Reagendar'), findsOneWidget);
    });
  });

  group('filters', () {
    testWidgets('proximity + probability + state go out in one request', (
      tester,
    ) async {
      final repos = await _pump(tester);

      await tester.tap(find.byTooltip('Filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('7 días'));
      await tester.tap(find.text('Alta (70+)'));
      await tester.tap(find.text('Completada'));
      await tester.pump();
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();

      final f = repos.upcoming.requests.last;
      expect(f.days, 7);
      expect(f.probabilityMin, 70);
      expect(f.probabilityMax, 100);
      expect(f.state, ActivityState.completed);
    });

    testWidgets('no results with filters offers to clear them', (tester) async {
      final repos = await _pump(tester);

      await tester.tap(find.byTooltip('Filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelada por el clima'));
      await tester.pump();
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();

      expect(find.text('Sin resultados'), findsOneWidget);

      await tester.tap(find.text('Limpiar filtros'));
      await tester.pumpAndSettle();

      expect(repos.upcoming.requests.last.isActive, isFalse);
      expect(find.text('Caminata'), findsOneWidget);
    });

    testWidgets('a probability filter explains it hides unknown ones', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.byTooltip('Filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Media (40–69)'));
      await tester.pump();

      expect(find.textContaining('sin pronóstico'), findsOneWidget);
    });
  });
}
