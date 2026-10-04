import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/design_system.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/locations/domain/entities/location_exceptions.dart';
import 'package:sky_plan/features/locations/presentation/screens/location_form_screen.dart';

import '../auth/auth_test_app.dart';
import 'locations_test_support.dart';

Future<void> _pump(
  WidgetTester tester, {
  required FakeVisitsRepository repo,
  FakeDeviceLocationRepository? device,
  Widget screen = const LocationFormScreen(),
}) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    buildLocationsTestApp(visits: repo, device: device, child: screen),
  );
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  final button = find.widgetWithText(SkyButton, 'Guardar ubicación');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty submit shows validation errors and calls nothing', (
    tester,
  ) async {
    final repo = FakeVisitsRepository();
    await _pump(tester, repo: repo);

    await _submit(tester);

    expect(find.text('El nombre es obligatorio'), findsOneWidget);
    expect(find.text('Elige una ubicación'), findsOneWidget);
    expect(find.text('Elige una fecha'), findsOneWidget);
    expect(repo.created, isEmpty);
  });

  testWidgets('GPS success shows the chosen coordinates', (tester) async {
    await _pump(tester, repo: FakeVisitsRepository());

    await tester.tap(find.text('Usar mi ubicación actual'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ubicación elegida'), findsOneWidget);
    expect(find.text('14.60000, -90.50000'), findsOneWidget);
  });

  testWidgets('denied GPS permission shows a retry alert', (tester) async {
    final device = FakeDeviceLocationRepository()
      ..error = const GpsPermissionDeniedException();
    await _pump(tester, repo: FakeVisitsRepository(), device: device);

    await tester.tap(find.text('Usar mi ubicación actual'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Necesitamos permiso de ubicación'), findsOne);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('permanently denied permission offers the system settings', (
    tester,
  ) async {
    final device = FakeDeviceLocationRepository()
      ..error = const GpsPermissionDeniedException(permanently: true);
    await _pump(tester, repo: FakeVisitsRepository(), device: device);

    await tester.tap(find.text('Usar mi ubicación actual'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir ajustes'));
    await tester.pumpAndSettle();

    expect(device.settingsOpened, 1);
  });

  testWidgets('disabled GPS service asks to turn it on', (tester) async {
    final device = FakeDeviceLocationRepository()
      ..error = const GpsDisabledException();
    await _pump(tester, repo: FakeVisitsRepository(), device: device);

    await tester.tap(find.text('Usar mi ubicación actual'));
    await tester.pumpAndSettle();

    expect(find.textContaining('El GPS está desactivado'), findsOneWidget);
    expect(find.text('Activar ubicación'), findsOneWidget);
  });

  testWidgets('editing sends only the changed fields', (tester) async {
    final repo = FakeVisitsRepository();
    await _pump(
      tester,
      repo: repo,
      screen: LocationFormScreen(visit: makeVisit(id: 5, name: 'Antigua')),
    );

    expect(find.text('Editar ubicación'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Antigua Guate');
    await _submit(tester);

    expect(repo.updated, hasLength(1));
    expect(repo.updated.single['id'], 5);
    expect(repo.updated.single['name'], 'Antigua Guate');
    expect(repo.updated.single['point'], isNull);
    expect(repo.updated.single['date'], isNull);
  });

  testWidgets('shows the API error (409 duplicate date) in the form', (
    tester,
  ) async {
    final repo = FakeVisitsRepository()
      ..error = const ApiException(
        status: 409,
        message: 'Ya tienes una ubicación registrada para esa fecha',
      );
    await _pump(
      tester,
      repo: repo,
      screen: LocationFormScreen(visit: makeVisit(id: 5, name: 'Antigua')),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Otro nombre');
    await _submit(tester);

    expect(
      find.text('Ya tienes una ubicación registrada para esa fecha'),
      findsOneWidget,
    );
  });
}
