import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/components/buttons/sky_button.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: SkyTheme.light,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('invokes onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(SkyButton(label: 'Guardar', onPressed: () => tapped = true)),
    );

    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('does not invoke onPressed when disabled', (tester) async {
    await tester.pumpWidget(
      _wrap(const SkyButton(label: 'Guardar', onPressed: null)),
    );

    await tester.tap(find.text('Guardar'), warnIfMissed: false);
    await tester.pump();

    // onPressed is null: reaching this line without throwing is the
    // assertion — InkWell.onTap is disabled, so there is nothing to await.
  });

  testWidgets('does not invoke onPressed while loading', (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      _wrap(
        SkyButton(label: 'Guardar', loading: true, onPressed: () => tapCount++),
      ),
    );

    await tester.tap(find.text('Guardar'), warnIfMissed: false);
    await tester.pump();

    expect(tapCount, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('respects the 44px minimum hit target for every size', (
    tester,
  ) async {
    for (final size in SkyButtonSize.values) {
      await tester.pumpWidget(
        _wrap(SkyButton(label: 'Guardar', size: size, onPressed: () {})),
      );
      final renderBox = tester.renderObject<RenderBox>(find.byType(SkyButton));
      expect(renderBox.size.height, greaterThanOrEqualTo(44));
    }
  });
}
