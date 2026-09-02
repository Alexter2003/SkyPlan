import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sky_plan/core/design_system/theme/sky_theme_context.dart';
import 'package:sky_plan/main.dart';

void main() {
  testWidgets('HomePage shows the SkyPlan wordmark', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      SkyThemeScope(
        controller: SkyThemeController(),
        child: const SkyPlanApp(),
      ),
    );

    expect(find.text('SkyPlan'), findsOneWidget);
    expect(
      find.text(kDebugMode ? 'Ver UI kit (/kit)' : 'Hello SkyPlan'),
      findsOneWidget,
    );
  });
}
