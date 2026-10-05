import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/components/selection/sky_chip.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme_context.dart';
import 'package:sky_plan/features/activities/presentation/widgets/weather_condition_selector.dart';

import 'activities_test_support.dart';

class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  Set<int> selected = {};

  @override
  Widget build(BuildContext context) {
    return WeatherConditionSelector(
      catalog: testCatalog,
      selected: selected,
      onChanged: (v) => setState(() => selected = v),
    );
  }
}

bool _enabled(WidgetTester tester, String name) =>
    tester.widget<SkyChip>(find.byKey(ValueKey('condition-$name'))).enabled;

void main() {
  testWidgets('selecting a condition disables the contradictory ones', (
    tester,
  ) async {
    await tester.pumpWidget(
      SkyThemeScope(
        controller: SkyThemeController(),
        child: MaterialApp(
          theme: SkyTheme.light,
          home: const Scaffold(body: _Harness()),
        ),
      ),
    );

    expect(_enabled(tester, 'rainy'), isTrue);

    await tester.tap(find.text('Soleado'));
    await tester.pump();
    expect(_enabled(tester, 'rainy'), isFalse);
    expect(_enabled(tester, 'windy'), isTrue);

    // Un chip deshabilitado no responde al toque.
    await tester.tap(find.text('Lluvia'));
    await tester.pump();
    expect(
      tester
          .widget<SkyChip>(find.byKey(const ValueKey('condition-rainy')))
          .selected,
      isFalse,
    );

    await tester.tap(find.text('Soleado'));
    await tester.pump();
    expect(_enabled(tester, 'rainy'), isTrue);
  });
}
