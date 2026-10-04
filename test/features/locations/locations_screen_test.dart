import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/design_system.dart';
import 'package:sky_plan/features/locations/domain/entities/visit.dart';
import 'package:sky_plan/features/locations/presentation/screens/locations_screen.dart';

import '../auth/auth_test_app.dart';
import 'locations_test_support.dart';

Future<void> _pump(WidgetTester tester, FakeVisitsRepository repo) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    buildLocationsTestApp(visits: repo, child: const LocationsScreen()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists planned visits with weather', (tester) async {
    await _pump(
      tester,
      FakeVisitsRepository([
        makeVisit(id: 1, name: 'Antigua Guatemala'),
        makeVisit(id: 2, name: 'Lago de Atitlán', withWeather: false),
      ]),
    );

    expect(find.text('Antigua Guatemala'), findsOneWidget);
    expect(find.text('Lago de Atitlán'), findsOneWidget);
    expect(find.text('Clima pendiente'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no visits', (tester) async {
    await _pump(tester, FakeVisitsRepository());

    expect(find.text('Aún no tienes ubicaciones'), findsOneWidget);
    expect(find.text('Registrar ubicación'), findsOneWidget);
  });

  testWidgets('delete asks for confirmation warning about the cascade', (
    tester,
  ) async {
    final repo = FakeVisitsRepository([makeVisit(id: 7, name: 'Tikal')]);
    await _pump(tester, repo);

    await tester.tap(find.byTooltip('Opciones'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SkyButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar «Tikal»?'), findsOneWidget);
    expect(
      find.textContaining('También se eliminarán todas las actividades'),
      findsOneWidget,
    );
    expect(repo.deletedIds, isEmpty);

    await tester.tap(find.widgetWithText(SkyButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(repo.deletedIds, [7]);
    expect(find.text('Tikal'), findsNothing);
    expect(find.text('Ubicación eliminada'), findsOneWidget);
  });

  testWidgets('cancelling the delete dialog keeps the visit', (tester) async {
    final repo = FakeVisitsRepository([makeVisit(id: 7, name: 'Tikal')]);
    await _pump(tester, repo);

    await tester.tap(find.byTooltip('Opciones'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SkyButton, 'Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SkyButton, 'Cancelar'));
    await tester.pumpAndSettle();

    expect(repo.deletedIds, isEmpty);
    expect(find.text('Tikal'), findsOneWidget);
  });

  testWidgets('frozen visits only offer delete', (tester) async {
    final repo = FakeVisitsRepository([
      makeVisit(id: 3, status: VisitStatus.completed),
    ]);
    await _pump(tester, repo);

    await tester.tap(find.text('FINALIZADAS'));
    await tester.pumpAndSettle();
    expect(find.text('Finalizada'), findsOneWidget);

    await tester.tap(find.byTooltip('Opciones'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(SkyButton, 'Eliminar'), findsOneWidget);
    expect(find.text('Editar'), findsNothing);
    expect(find.text('Cancelar visita'), findsNothing);
    expect(find.text('Marcar como finalizada'), findsNothing);
  });

  testWidgets('complete is hidden for a future planned visit', (tester) async {
    await _pump(tester, FakeVisitsRepository([makeVisit()]));

    await tester.tap(find.byTooltip('Opciones'));
    await tester.pumpAndSettle();

    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Cancelar visita'), findsOneWidget);
    expect(find.text('Marcar como finalizada'), findsNothing);
  });

  testWidgets('the new-location button is visible with no data', (
    tester,
  ) async {
    await _pump(tester, FakeVisitsRepository());

    expect(find.widgetWithText(SkyButton, 'Nueva ubicación'), findsOneWidget);
  });

  testWidgets('the new-location button stays visible when there is data', (
    tester,
  ) async {
    await _pump(tester, FakeVisitsRepository([makeVisit()]));

    expect(find.text('Antigua Guatemala'), findsOneWidget);
    expect(find.widgetWithText(SkyButton, 'Nueva ubicación'), findsOneWidget);
  });
}
