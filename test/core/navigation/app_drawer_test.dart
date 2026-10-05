import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/navigation/app_drawer.dart';
import 'package:sky_plan/core/routing/app_routes.dart';

import '../../features/auth/auth_test_app.dart';
import '../../features/locations/locations_test_support.dart';

class _Host extends StatelessWidget {
  const _Host({required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentRoute: currentRoute),
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          child: const Text('open'),
        ),
      ),
    );
  }
}

Future<void> _openDrawer(WidgetTester tester, String currentRoute) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    buildLocationsTestApp(
      visits: FakeVisitsRepository(),
      child: _Host(currentRoute: currentRoute),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows sections, with unfinished ones disabled', (tester) async {
    await _openDrawer(tester, AppRoutes.home);

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Mis ubicaciones'), findsOneWidget);
    expect(find.text('Actividades'), findsOneWidget);
    expect(find.text('Pronto'), findsNWidgets(2));
  });

  testWidgets('navigates to Mis ubicaciones', (tester) async {
    await _openDrawer(tester, AppRoutes.home);

    await tester.tap(find.text('Mis ubicaciones'));
    await tester.pumpAndSettle();

    expect(find.text('route:locations'), findsOneWidget);
  });

  testWidgets('tapping the current section only closes the drawer', (
    tester,
  ) async {
    await _openDrawer(tester, AppRoutes.locations);

    await tester.tap(find.text('Mis ubicaciones'));
    await tester.pumpAndSettle();

    expect(find.text('route:locations'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('logout goes back to the login route', (tester) async {
    await _openDrawer(tester, AppRoutes.home);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('route:login'), findsOneWidget);
  });
}
