import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';
import 'package:sky_plan/features/activities/presentation/screens/visit_activities_screen.dart';
import 'package:sky_plan/features/locations/domain/entities/visit.dart';

import '../locations/locations_test_support.dart';
import 'activities_test_support.dart';

void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<FakeActivitiesRepository> _pump(
  WidgetTester tester,
  List<Activity> activities,
) async {
  _tall(tester);
  final repo = FakeActivitiesRepository(activities);
  await tester.pumpWidget(
    buildActivitiesTestApp(
      visits: FakeVisitsRepository([makeVisit()]),
      activities: repo,
      child: VisitActivitiesScreen(visit: makeVisit()),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('shows "2 de 5 completadas" with a progress bar', (tester) async {
    await _pump(tester, [
      makeActivity(id: 1, name: 'A', start: '08:00', end: '09:00'),
      makeActivity(
        id: 2,
        name: 'B',
        start: '09:00',
        end: '10:00',
        state: ActivityState.completed,
      ),
      makeActivity(
        id: 3,
        name: 'C',
        start: '10:00',
        end: '11:00',
        state: ActivityState.completed,
      ),
      makeActivity(id: 4, name: 'D', start: '11:00', end: '12:00'),
      makeActivity(id: 5, name: 'E', start: '12:00', end: '13:00'),
    ]);

    expect(find.text('2 de 5 completadas'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('checking an activity updates the count', (tester) async {
    final repo = await _pump(tester, [
      makeActivity(id: 1, name: 'A', start: '08:00', end: '09:00'),
      makeActivity(id: 2, name: 'B', start: '09:00', end: '10:00'),
    ]);
    expect(find.text('0 de 2 completadas'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('complete-checkbox')).first);
    await tester.pumpAndSettle();

    expect(repo.actions, ['complete:1']);
    expect(find.text('1 de 2 completadas'), findsOneWidget);
  });

  testWidgets('unchecking a completed activity undoes it', (tester) async {
    final repo = await _pump(tester, [
      makeActivity(id: 1, state: ActivityState.completed),
    ]);
    expect(find.text('1 de 1 completadas'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('complete-checkbox')));
    await tester.pumpAndSettle();

    expect(repo.actions, ['uncomplete:1']);
    expect(find.text('0 de 1 completadas'), findsOneWidget);
  });

  testWidgets('the visit shows finished when completing closes it', (
    tester,
  ) async {
    _tall(tester);
    final repo = FakeActivitiesRepository([makeActivity(id: 1)])
      ..nextVisitStatus = VisitStatus.completed;
    await tester.pumpWidget(
      buildActivitiesTestApp(
        visits: FakeVisitsRepository([makeVisit()]),
        activities: repo,
        child: VisitActivitiesScreen(visit: makeVisit()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ubicación finalizada'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('complete-checkbox')));
    await tester.pumpAndSettle();

    expect(find.text('Ubicación finalizada'), findsOneWidget);

    repo.nextVisitStatus = VisitStatus.planned;
    await tester.tap(find.byKey(const ValueKey('complete-checkbox')));
    await tester.pumpAndSettle();

    expect(find.text('Ubicación finalizada'), findsNothing);
  });

  testWidgets('cancelled activities do not count toward the total', (
    tester,
  ) async {
    await _pump(tester, [
      makeActivity(id: 1, start: '08:00', end: '09:00'),
      makeActivity(
        id: 2,
        start: '09:00',
        end: '10:00',
        state: ActivityState.cancelledBySystem,
      ),
    ]);

    expect(find.text('0 de 1 completadas'), findsOneWidget);
    expect(find.byKey(const ValueKey('complete-checkbox')), findsOneWidget);
  });

  testWidgets('an API refusal reverts the checkbox and shows the message', (
    tester,
  ) async {
    final repo = await _pump(tester, [makeActivity(id: 1)]);
    repo.error = const ApiException(
      status: 400,
      message: 'No puedes finalizar una visita cuya fecha aún no ha llegado',
    );

    await tester.tap(find.byKey(const ValueKey('complete-checkbox')));
    await tester.pumpAndSettle();

    expect(find.text('0 de 1 completadas'), findsOneWidget);
    expect(
      find.text('No puedes finalizar una visita cuya fecha aún no ha llegado'),
      findsOneWidget,
    );
  });

  testWidgets('no activities hides the progress', (tester) async {
    await _pump(tester, const []);

    expect(find.textContaining('completadas'), findsNothing);
  });
}
