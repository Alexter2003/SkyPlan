import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/components/selection/sky_segmented_control.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';

enum _ActivityType { exterior, interior }

void main() {
  testWidgets('selecting a segment calls onChanged with that value', (
    tester,
  ) async {
    _ActivityType? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: SkyTheme.light,
        home: Scaffold(
          body: SkySegmentedControl<_ActivityType>(
            value: _ActivityType.exterior,
            options: _ActivityType.values,
            optionLabel: (v) =>
                v == _ActivityType.exterior ? 'Exterior' : 'Interior',
            onChanged: (v) => selected = v,
          ),
        ),
      ),
    );

    await tester.tap(find.text('INTERIOR'));
    await tester.pump();

    expect(selected, _ActivityType.interior);
  });
}
