import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/components/inputs/sky_code_field.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';

void main() {
  testWidgets('uppercases input and calls onCompleted at full length', (
    tester,
  ) async {
    String? completed;

    await tester.pumpWidget(
      MaterialApp(
        theme: SkyTheme.light,
        home: Scaffold(
          body: SkyCodeField(
            length: 5,
            onCompleted: (value) => completed = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'a1b2c');
    await tester.pump();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(completed, 'A1B2C');
  });

  testWidgets('clear() empties the field', (tester) async {
    final key = GlobalKey<SkyCodeFieldState>();

    await tester.pumpWidget(
      MaterialApp(
        theme: SkyTheme.light,
        home: Scaffold(body: SkyCodeField(key: key, length: 5)),
      ),
    );

    await tester.enterText(find.byType(TextField), 'ABCDE');
    await tester.pump();
    expect(find.text('A'), findsOneWidget);

    key.currentState?.clear();
    await tester.pump();
    expect(find.text('A'), findsNothing);
  });
}
