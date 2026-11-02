import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/cancel_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/complete_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/reactivate_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/uncomplete_activity.dart';
import 'package:sky_plan/features/pending/domain/entities/upcoming_filters.dart';
import 'package:sky_plan/features/pending/domain/usecases/get_upcoming_activities.dart';
import 'package:sky_plan/features/pending/presentation/state/pending_activities_controller.dart';

import '../activities/activities_test_support.dart';
import 'pending_test_support.dart';

({
  PendingActivitiesController controller,
  FakeUpcomingRepository upcoming,
  FakeActivitiesRepository activities,
})
_build() {
  final upcoming = FakeUpcomingRepository([
    makeUpcoming(id: 1, visitId: 1, probability: 80),
    makeUpcoming(id: 2, visitId: 2, probability: 20, band: ProbabilityBand.red),
    makeUpcoming(id: 3, visitId: 1, probability: null, band: null),
  ]);
  final activities = FakeActivitiesRepository([
    makeActivity(id: 1),
    makeActivity(id: 2),
    makeActivity(id: 3),
  ]);
  final controller = PendingActivitiesController(
    getUpcoming: GetUpcomingActivities(upcoming),
    completeActivity: CompleteActivity(activities),
    uncompleteActivity: UncompleteActivity(activities),
    cancelActivity: CancelActivity(activities),
    reactivateActivity: ReactivateActivity(activities),
  );
  return (controller: controller, upcoming: upcoming, activities: activities);
}

void main() {
  test('load fills the list from the server', () async {
    final b = _build();

    await b.controller.load();

    expect(b.controller.items.map((i) => i.id), [1, 2, 3]);
    expect(b.controller.hasLoaded, isTrue);
    expect(b.controller.errorMessage, isNull);
  });

  test('a load error is exposed and keeps the previous list', () async {
    final b = _build();
    await b.controller.load();
    b.upcoming.error = const NetworkException();

    await b.controller.load(silent: true);

    expect(b.controller.errorMessage, isNotNull);
    expect(b.controller.items, hasLength(3));
  });

  group('combined filters', () {
    test('location + probability are applied together', () async {
      final b = _build();
      await b.controller.load();

      await b.controller.applyFilters(
        const UpcomingFilters(visitId: 1, probabilityMin: 40),
      );

      expect(b.controller.items.map((i) => i.id), [1]);
      expect(b.upcoming.requests.last.visitId, 1);
      expect(b.upcoming.requests.last.probabilityMin, 40);
      expect(b.controller.hasFilters, isTrue);
    });

    test('probability filters drop activities without probability', () async {
      final b = _build();

      await b.controller.applyFilters(
        const UpcomingFilters(probabilityMax: 100),
      );

      expect(b.controller.items.map((i) => i.id), [1, 2]);
    });

    test('clearFilters brings the full list back', () async {
      final b = _build();
      await b.controller.applyFilters(const UpcomingFilters(visitId: 2));
      expect(b.controller.items, hasLength(1));

      await b.controller.clearFilters();

      expect(b.controller.items, hasLength(3));
      expect(b.controller.hasFilters, isFalse);
    });
  });

  group('checkbox', () {
    test('completing updates the item and the visit status', () async {
      final b = _build();
      await b.controller.load();

      final error = await b.controller.toggleComplete(b.controller.items[0]);

      expect(error, isNull);
      expect(b.controller.items[0].activity.state, ActivityState.completed);
      expect(b.activities.actions, ['complete:1']);
      expect(b.controller.busyIds, isEmpty);
    });

    test('unchecking a completed item sends uncomplete', () async {
      final b = _build();
      await b.controller.load();
      await b.controller.toggleComplete(b.controller.items[0]);

      await b.controller.toggleComplete(b.controller.items[0]);

      expect(b.controller.items[0].activity.state, ActivityState.planned);
      expect(b.activities.actions, ['complete:1', 'uncomplete:1']);
    });

    test('the checkbox is optimistic and reverts on error', () async {
      final b = _build();
      await b.controller.load();
      b.activities.error = const ApiException(
        status: 400,
        message: 'No puedes finalizar una visita cuya fecha aún no ha llegado',
      );
      final states = <ActivityState>[];
      b.controller.addListener(
        () => states.add(b.controller.items[0].activity.state),
      );

      final error = await b.controller.toggleComplete(b.controller.items[0]);

      expect(states.first, ActivityState.completed);
      expect(
        error?.message,
        'No puedes finalizar una visita cuya fecha aún no ha llegado',
      );
      expect(b.controller.items[0].activity.state, ActivityState.planned);
    });
  });

  group('actions replace the item from the response', () {
    test('cancel marks it cancelled with the reason', () async {
      final b = _build();
      await b.controller.load();

      final error = await b.controller.cancel(
        b.controller.items[1],
        reason: 'Me enfermé',
      );

      expect(error, isNull);
      expect(b.controller.items[1].activity.state, ActivityState.cancelled);
      expect(b.controller.items[1].activity.cancelReason, 'Me enfermé');
      expect(b.controller.items[1].visit.name, 'Antigua Guatemala');
    });

    test('reactivate returns the activity to planned', () async {
      final b = _build();
      await b.controller.load();
      await b.controller.cancel(b.controller.items[0]);

      final error = await b.controller.reactivate(b.controller.items[0]);

      expect(error, isNull);
      expect(b.controller.items[0].activity.state, ActivityState.planned);
    });

    test('an action error is returned and the item is untouched', () async {
      final b = _build();
      await b.controller.load();
      b.activities.error = const ApiException(
        status: 409,
        message:
            "El horario se cruza con la actividad 'Almuerzo' (15:00–17:00)",
      );

      final error = await b.controller.reactivate(b.controller.items[0]);

      expect(error?.message, contains('Almuerzo'));
      expect(error?.offerReschedule, isTrue);
      expect(b.controller.items[0].activity.state, ActivityState.planned);
    });

    test(
      'applyRescheduled refetches because the day may have changed',
      () async {
        final b = _build();
        await b.controller.load();
        final before = b.upcoming.requests.length;

        await b.controller.applyRescheduled(makeActivity(id: 1));

        expect(b.upcoming.requests.length, before + 1);
      },
    );
  });

  test('a stale response never overwrites a newer one', () async {
    final b = _build();

    final first = b.controller.applyFilters(const UpcomingFilters(visitId: 2));
    final second = b.controller.applyFilters(const UpcomingFilters(visitId: 1));
    await Future.wait([first, second]);

    expect(b.controller.filters.visitId, 1);
    expect(b.controller.items.every((i) => i.visit.id == 1), isTrue);
  });

  test('an ended activity on reactivate also offers reschedule', () async {
    final b = _build();
    await b.controller.load();
    b.activities.error = const ApiException(
      status: 400,
      message: 'La actividad ya terminó, reagéndala para otra fecha u horario',
    );

    final error = await b.controller.reactivate(b.controller.items[0]);

    expect(error?.offerReschedule, isTrue);
  });

  test('other errors do not offer reschedule', () async {
    final b = _build();
    await b.controller.load();
    b.activities.error = const ApiException(
      status: 404,
      message: 'Actividad no encontrada',
    );

    final error = await b.controller.cancel(b.controller.items[0]);

    expect(error?.message, 'Actividad no encontrada');
    expect(error?.offerReschedule, isFalse);
  });
}
