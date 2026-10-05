import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/components/buttons/sky_button.dart';
import 'package:sky_plan/features/activities/presentation/screens/activities_screen.dart';
import 'package:sky_plan/features/activities/presentation/screens/activity_form_screen.dart';
import 'package:sky_plan/features/activities/presentation/widgets/activity_card.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';

import '../auth/auth_test_app.dart';
import '../locations/locations_test_support.dart';
import 'activities_test_support.dart';

void main() {
  testWidgets('groups activities under their location', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildActivitiesTestApp(
        visits: FakeVisitsRepository([
          makeVisit(id: 1, name: 'Antigua'),
          makeVisit(id: 2, name: 'Atitlán'),
        ]),
        activities: FakeActivitiesRepository([
          makeActivity(id: 1, visitId: 1, name: 'Caminata'),
          makeActivity(
            id: 2,
            visitId: 2,
            name: 'Museo',
            type: ActivityType.indoor,
          ),
        ]),
        child: const ActivitiesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Antigua'), findsOneWidget);
    expect(find.text('Atitlán'), findsOneWidget);
    expect(find.text('Caminata'), findsOneWidget);
    expect(find.text('Museo'), findsOneWidget);
    expect(find.text('Al aire libre'), findsOneWidget);
    expect(find.text('Interior'), findsOneWidget);
  });

  testWidgets('shows the viability state of outdoor activities', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildActivitiesTestApp(
        visits: FakeVisitsRepository([makeVisit()]),
        activities: FakeActivitiesRepository([
          makeActivity(
            id: 1,
            name: 'A',
            isViable: true,
            start: '08:00',
            end: '09:00',
          ),
          makeActivity(
            id: 2,
            name: 'B',
            isViable: false,
            start: '10:00',
            end: '11:00',
          ),
          makeActivity(
            id: 3,
            name: 'C',
            isViable: null,
            start: '12:00',
            end: '13:00',
          ),
        ]),
        child: const ActivitiesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Viable'), findsOneWidget);
    expect(find.text('No viable por el clima'), findsOneWidget);
    expect(find.text('Pendiente de validar'), findsOneWidget);
  });

  testWidgets('delete asks for confirmation and then removes the activity', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final repo = FakeActivitiesRepository([makeActivity(name: 'Caminata')]);
    await tester.pumpWidget(
      buildActivitiesTestApp(
        visits: FakeVisitsRepository([makeVisit()]),
        activities: repo,
        child: const ActivitiesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Opciones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar «Caminata»?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repo.deletedIds, isEmpty);

    await tester.tap(find.byTooltip('Opciones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SkyButton, 'Eliminar').last);
    await tester.pumpAndSettle();

    expect(repo.deletedIds, [1]);
    expect(find.text('Caminata'), findsNothing);
  });

  testWidgets('card hides edit for non-planned activities', (tester) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildActivitiesTestApp(
        visits: FakeVisitsRepository([makeVisit()]),
        activities: FakeActivitiesRepository(),
        child: Scaffold(
          body: ActivityCard(
            activity: makeActivity(state: ActivityState.completed),
            busy: false,
            onAction: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Completada'), findsOneWidget);
    await tester.tap(find.byTooltip('Opciones'));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsNothing);
    expect(find.text('Eliminar'), findsOneWidget);
  });

  testWidgets('creation form shows the location weather as a header', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await tester.pumpWidget(
      buildActivitiesTestApp(
        visits: FakeVisitsRepository([makeVisit(name: 'Antigua')]),
        activities: FakeActivitiesRepository(),
        child: ActivityFormScreen(visit: makeVisit(name: 'Antigua')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('22 °C'), findsOneWidget);
    expect(find.text('Templado'), findsOneWidget);
    expect(find.text('Llovizna'), findsOneWidget);
    expect(find.text('Parcialmente nublado'), findsOneWidget);
    expect(find.text('Viento suave'), findsOneWidget);
  });
}
