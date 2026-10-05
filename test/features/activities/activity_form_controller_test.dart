import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/create_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/get_activities_by_visit.dart';
import 'package:sky_plan/features/activities/domain/usecases/get_weather_conditions.dart';
import 'package:sky_plan/features/activities/domain/usecases/update_activity.dart';
import 'package:sky_plan/features/activities/presentation/state/activity_form_controller.dart';
import 'package:sky_plan/features/locations/domain/usecases/get_visits.dart';

import '../locations/locations_test_support.dart';
import 'activities_test_support.dart';

ActivityFormController buildController(
  FakeActivitiesRepository repo, {
  Activity? editing,
}) {
  final visit = makeVisit();
  return ActivityFormController(
    createActivity: CreateActivity(repo),
    updateActivity: UpdateActivity(repo),
    getConditions: GetWeatherConditions(FakeWeatherConditionsRepository()),
    getActivities: GetActivitiesByVisit(repo),
    getVisits: GetVisits(FakeVisitsRepository([visit])),
    editing: editing,
    visit: visit,
  );
}

void main() {
  test('flags a crossing schedule before calling the backend', () async {
    final repo = FakeActivitiesRepository([
      makeActivity(id: 1, name: 'Almuerzo', start: '10:00', end: '12:00'),
    ]);
    final controller = buildController(repo);
    await controller.init();

    controller
      ..setStart(t('11:00'))
      ..setEnd(t('13:00'))
      ..setConditions({1});
    final saved = await controller.submit(name: 'Yoga', description: 'x');

    expect(saved, isNull);
    expect(controller.timeError, contains("'Almuerzo' (10:00–12:00)"));
    expect(repo.created, isEmpty);
  });

  test('rejects an end time that is not after the start', () async {
    final controller = buildController(FakeActivitiesRepository());
    await controller.init();

    controller
      ..setStart(t('12:00'))
      ..setEnd(t('11:00'));

    expect(controller.timeError, contains('anterior'));
  });

  test('requires at least one weather condition', () async {
    final controller = buildController(FakeActivitiesRepository());
    await controller.init();
    controller
      ..setStart(t('09:00'))
      ..setEnd(t('10:00'));

    expect(controller.validateSelection(), isFalse);
    expect(controller.conditionsError, isNotNull);
  });

  test('creates with the selected conditions', () async {
    final repo = FakeActivitiesRepository();
    final controller = buildController(repo);
    await controller.init();
    controller
      ..setStart(t('09:00'))
      ..setEnd(t('10:00'))
      ..setConditions({3, 1});

    final saved = await controller.submit(name: 'Yoga', description: 'x');

    expect(saved, isNotNull);
    expect(repo.created.single['weatherConditionIds'], [1, 3]);
  });

  test('a 422 shows the backend message with a suggestion', () async {
    final repo = FakeActivitiesRepository()
      ..error = const ApiException(
        status: 422,
        message: 'No se puede guardar la actividad: pronóstico de lluvia',
      );
    final controller = buildController(repo);
    await controller.init();
    repo.error = const ApiException(
      status: 422,
      message: 'No se puede guardar la actividad: pronóstico de lluvia',
    );
    controller
      ..setStart(t('09:00'))
      ..setEnd(t('10:00'))
      ..setConditions({1});

    final saved = await controller.submit(name: 'Yoga', description: 'x');

    expect(saved, isNull);
    expect(controller.errorMessage, contains('pronóstico de lluvia'));
    expect(controller.errorMessage, contains('cambiar las condiciones'));
  });

  test('editing sends only the changed fields', () async {
    final repo = FakeActivitiesRepository();
    final controller = buildController(
      repo,
      editing: makeActivity(id: 7, name: 'Caminata'),
    );
    await controller.init();

    await controller.submit(
      name: 'Caminata larga',
      description: 'Cerro de la Cruz',
    );

    final sent = repo.updated.single;
    expect(sent['name'], 'Caminata larga');
    expect(sent['startTime'], isNull);
    expect(sent['weatherConditionIds'], isNull);
  });

  test('editing does not flag overlap with itself', () async {
    final editing = makeActivity(id: 7, start: '09:00', end: '11:00');
    final repo = FakeActivitiesRepository([editing]);
    final controller = buildController(repo, editing: editing);
    await controller.init();

    controller.setEnd(t('11:30'));

    expect(controller.timeError, isNull);
  });
}
