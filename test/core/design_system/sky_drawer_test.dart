import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/design_system.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: SkyTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('selected item still taps; disabled shows badge and ignores', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            SkyDrawerItem(
              icon: SkyIconType.home,
              label: 'Inicio',
              selected: true,
              onTap: () => taps++,
            ),
            SkyDrawerItem(
              icon: SkyIconType.calendar,
              label: 'Actividades',
              enabled: false,
              onTap: () => taps++,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Inicio'));
    await tester.tap(find.text('Actividades'));

    expect(taps, 1);
    expect(find.text('Pronto'), findsOneWidget);
  });

  testWidgets('loading item shows a spinner and ignores taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        SkyDrawerItem(
          icon: SkyIconType.logout,
          label: 'Cerrar sesión',
          loading: true,
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.text('Cerrar sesión'));

    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
