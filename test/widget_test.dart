import 'package:flutter_test/flutter_test.dart';

import 'package:sky_plan/main.dart';

void main() {
  testWidgets('HomePage shows greeting', (WidgetTester tester) async {
    await tester.pumpWidget(const SkyPlanApp());

    expect(find.text('SkyPlan'), findsOneWidget);
    expect(find.text('Hello SkyPlan'), findsOneWidget);
  });
}
