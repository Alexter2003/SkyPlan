import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/components/selection/sky_checkbox.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';

void main() {
  testWidgets('toggles value on tap', (tester) async {
    var value = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: SkyTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SkyCheckbox(
              value: value,
              label: 'Comprar hielo',
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      ),
    );

    expect(value, isFalse);
    await tester.tap(find.text('Comprar hielo'));
    await tester.pump();
    expect(value, isTrue);
  });
}
