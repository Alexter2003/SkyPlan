import 'package:flutter_test/flutter_test.dart';

import 'package:sky_plan/core/design_system/theme/sky_theme_context.dart';
import 'package:sky_plan/main.dart';

void main() {
  testWidgets('App boots to the login screen when there is no session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      SkyThemeScope(
        controller: SkyThemeController(),
        child: const SkyPlanApp(),
      ),
    );

    // Avanza el reloj para superar el timeout del bootstrap de sesión.
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('SkyPlan'), findsWidgets);
    expect(find.text('Bienvenido de vuelta'), findsOneWidget);
  });
}
