import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/activities/domain/usecases/reschedule_activity.dart';
import 'package:sky_plan/features/activities/presentation/state/reschedule_controller.dart';

import '../activities/activities_test_support.dart';

RescheduleController _build(FakeActivitiesRepository repo, {DateTime? today}) =>
    RescheduleController(
      rescheduleActivity: RescheduleActivity(repo),
      activity: makeActivity(id: 5, start: '09:00', end: '11:00'),
      today: today ?? DateTime(2030, 1, 1),
    );

void main() {
  test('starts from the activity schedule', () {
    final c = _build(FakeActivitiesRepository());

    expect(c.date, DateTime(2030, 1, 10));
    expect(c.startTime, t('09:00'));
    expect(c.endTime, t('11:00'));
  });

  test('a past activity date starts from today', () {
    final c = _build(FakeActivitiesRepository(), today: DateTime(2031, 6, 1));

    expect(c.date, DateTime(2031, 6, 1));
  });

  test('start not before end is rejected without calling the API', () async {
    final repo = FakeActivitiesRepository();
    final c = _build(repo)..setStart(t('12:00'));

    final result = await c.submit();

    expect(result, isNull);
    expect(c.timeError, 'La hora de inicio debe ser anterior a la hora de fin');
    expect(repo.rescheduled, isEmpty);
  });

  test('a past date is rejected without calling the API', () async {
    final repo = FakeActivitiesRepository();
    final c = _build(repo)..setDate(DateTime(2029, 12, 31));

    final result = await c.submit();

    expect(result, isNull);
    expect(c.dateError, 'La fecha no puede estar en el pasado');
    expect(repo.rescheduled, isEmpty);
  });

  test('a valid schedule is sent and returned', () async {
    final repo = FakeActivitiesRepository([makeActivity(id: 5)]);
    final c = _build(repo)
      ..setDate(DateTime(2030, 1, 12, 15))
      ..setStart(t('14:00'))
      ..setEnd(t('16:00'));

    final result = await c.submit();

    expect(result, isNotNull);
    expect(repo.rescheduled.single['date'], DateTime(2030, 1, 12));
    expect(repo.rescheduled.single['startTime'], t('14:00'));
    expect(c.isSubmitting, isFalse);
    expect(c.serverError, isNull);
  });

  for (final (status, message) in [
    (409, "El horario se cruza con la actividad 'Almuerzo' (15:00–17:00)"),
    (409, 'Ya tienes una ubicación registrada para esa fecha en otro lugar'),
    (
      422,
      'No se puede guardar la actividad: para el 2030-01-12 el pronóstico '
          'indica lluvia, incompatible con: soleado',
    ),
  ]) {
    test('$status is shown verbatim and editing clears it', () async {
      final repo = FakeActivitiesRepository([makeActivity(id: 5)])
        ..error = ApiException(status: status, message: message);
      final c = _build(repo);

      final result = await c.submit();

      expect(result, isNull);
      expect(c.serverError, message);

      c.setEnd(t('12:00'));
      expect(c.serverError, isNull);
    });
  }
}
