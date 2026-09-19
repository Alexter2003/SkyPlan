import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/components/feedback/sky_inline_alert.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';

void main() {
  testWidgets('renders the message and detail lines', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SkyTheme.light,
        home: const Scaffold(
          body: SkyInlineAlert(
            message: 'Ya existe un usuario registrado con ese correo',
            details: ['detalle adicional'],
          ),
        ),
      ),
    );

    expect(
      find.text('Ya existe un usuario registrado con ese correo'),
      findsOneWidget,
    );
    expect(find.text('• detalle adicional'), findsOneWidget);
  });

  testWidgets('invokes onAction when the action label is tapped', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: SkyTheme.light,
        home: Scaffold(
          body: SkyInlineAlert(
            message: 'Debes confirmar tu correo antes de iniciar sesión',
            tone: SkyInlineAlertTone.warning,
            actionLabel: 'Confirmar ahora',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Confirmar ahora'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
