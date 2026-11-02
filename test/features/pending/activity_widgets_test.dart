import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';
import 'package:sky_plan/features/activities/domain/services/activity_operations.dart';
import 'package:sky_plan/features/activities/presentation/widgets/activity_action_dialogs.dart';
import 'package:sky_plan/features/activities/presentation/widgets/activity_state_badge.dart';
import 'package:sky_plan/features/activities/presentation/widgets/probability_indicator.dart';

import '../activities/activities_test_support.dart';
import '../auth/auth_test_app.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  usePhoneViewport(tester);
  await tester.pumpWidget(
    MaterialApp(
      theme: SkyTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('ProbabilityIndicator', () {
    for (final (band, percent, label) in [
      (ProbabilityBand.green, 80, 'Alta'),
      (ProbabilityBand.yellow, 55, 'Media'),
      (ProbabilityBand.red, 10, 'Baja'),
    ]) {
      testWidgets('${band.name} shows percentage and text label', (
        tester,
      ) async {
        await _pump(
          tester,
          ProbabilityIndicator(
            activity: makeActivity(probability: percent, band: band),
          ),
        );

        expect(find.text('$percent% · $label'), findsOneWidget);
        expect(
          find.byKey(ValueKey('probability-${band.name}')),
          findsOneWidget,
        );
        expect(find.text('Probabilidad de realización'), findsOneWidget);
      });
    }

    testWidgets('null probability shows "Pendiente de validar" only', (
      tester,
    ) async {
      await _pump(
        tester,
        ProbabilityIndicator(
          activity: makeActivity(probability: null, band: null),
        ),
      );

      expect(find.text('Pendiente de validar'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
    });
  });

  group('ActivityStateBadge', () {
    testWidgets('the four states have distinct labels', (tester) async {
      final labels = <String>{};
      for (final state in ActivityState.values) {
        await _pump(tester, ActivityStateBadge(state: state));
        labels.add(ActivityStateBadge.labelOf(state));
        expect(find.text(ActivityStateBadge.labelOf(state)), findsOneWidget);
      }
      expect(labels, hasLength(4));
      expect(
        ActivityStateBadge.labelOf(ActivityState.cancelledBySystem),
        isNot(ActivityStateBadge.labelOf(ActivityState.cancelled)),
      );
    });

    test('each state has its own icon', () {
      final icons = {
        for (final s in ActivityState.values) ActivityStateBadge.iconOf(s),
      };
      expect(icons, hasLength(4));
    });
  });

  group('availableOperations', () {
    test('planned can complete, cancel and reschedule', () {
      expect(availableOperations(ActivityState.planned), {
        ActivityOperation.complete,
        ActivityOperation.cancel,
        ActivityOperation.reschedule,
      });
    });

    test('completed can only be undone', () {
      expect(availableOperations(ActivityState.completed), {
        ActivityOperation.uncomplete,
      });
    });

    test('both cancelled states can reactivate or reschedule', () {
      for (final state in [
        ActivityState.cancelled,
        ActivityState.cancelledBySystem,
      ]) {
        expect(availableOperations(state), {
          ActivityOperation.reactivate,
          ActivityOperation.reschedule,
        });
      }
    });

    test('the checkbox only applies to planned and completed', () {
      expect(canToggleComplete(ActivityState.planned), isTrue);
      expect(canToggleComplete(ActivityState.completed), isTrue);
      expect(canToggleComplete(ActivityState.cancelled), isFalse);
      expect(canToggleComplete(ActivityState.cancelledBySystem), isFalse);
    });
  });

  group('cancel dialog', () {
    Future<({CancelDecision? Function() decision, bool Function() done})> open(
      WidgetTester tester,
    ) async {
      usePhoneViewport(tester);
      CancelDecision? result;
      var done = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: SkyTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await confirmCancelActivity(
                    context,
                    makeActivity(name: 'Caminata'),
                  );
                  done = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return (decision: () => result, done: () => done);
    }

    testWidgets('confirming without a reason returns a null reason', (
      tester,
    ) async {
      final sheet = await open(tester);

      await tester.tap(find.text('Cancelar actividad'));
      await tester.pumpAndSettle();

      expect(sheet.done(), isTrue);
      expect(sheet.decision(), isNotNull);
      expect(sheet.decision()!.reason, isNull);
    });

    testWidgets('confirming returns the trimmed reason', (tester) async {
      final sheet = await open(tester);

      await tester.enterText(find.byType(TextFormField), '  Me enfermé  ');
      await tester.tap(find.text('Cancelar actividad'));
      await tester.pumpAndSettle();

      expect(sheet.decision()!.reason, 'Me enfermé');
    });

    testWidgets('a reason longer than 500 characters is rejected', (
      tester,
    ) async {
      final sheet = await open(tester);

      await tester.enterText(find.byType(TextFormField), 'a' * 501);
      await tester.tap(find.text('Cancelar actividad'));
      await tester.pumpAndSettle();

      expect(
        find.text('El motivo no puede superar los 500 caracteres'),
        findsOneWidget,
      );
      expect(sheet.done(), isFalse);
    });

    testWidgets('"Volver" dismisses without a decision', (tester) async {
      final sheet = await open(tester);

      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();

      expect(sheet.done(), isTrue);
      expect(sheet.decision(), isNull);
    });
  });

  group('confirmReactivate', () {
    Future<bool> run(
      WidgetTester tester,
      Activity activity, {
      String? tap,
    }) async {
      usePhoneViewport(tester);
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: SkyTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async =>
                    result = await confirmReactivate(context, activity),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      if (tap != null) {
        await tester.tap(find.text(tap));
        await tester.pumpAndSettle();
      }
      return result ?? false;
    }

    testWidgets('green or unknown band needs no extra confirmation', (
      tester,
    ) async {
      final ok = await run(
        tester,
        makeActivity(probability: 80, band: ProbabilityBand.green),
      );

      expect(ok, isTrue);
      expect(find.text('El clima sigue mal'), findsNothing);
    });

    testWidgets('red band asks first and honors the answer', (tester) async {
      final ok = await run(
        tester,
        makeActivity(probability: 10, band: ProbabilityBand.red),
        tap: 'Reactivar',
      );

      expect(ok, isTrue);
    });

    testWidgets('red band cancel keeps it cancelled', (tester) async {
      final ok = await run(
        tester,
        makeActivity(probability: 10, band: ProbabilityBand.red),
        tap: 'Cancelar',
      );

      expect(ok, isFalse);
    });
  });
}
