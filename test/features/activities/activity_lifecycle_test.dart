import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sky_plan/core/network/api_client.dart';
import 'package:sky_plan/core/network/api_exception.dart';
import 'package:sky_plan/features/activities/data/datasources/activities_remote_datasource.dart';
import 'package:sky_plan/features/activities/data/repositories/activities_repository_impl.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/cancel_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/complete_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/reactivate_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/reschedule_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/uncomplete_activity.dart';
import 'package:sky_plan/features/locations/domain/entities/visit.dart';

import 'activities_test_support.dart';

Map<String, dynamic> _activityJson(String state, {Object? extra}) => {
  'id': 5,
  'visitId': 10,
  'name': 'Caminata',
  'description': '',
  'date': '2026-11-03',
  'startTime': '15:00',
  'endTime': '17:00',
  'type': 'OUTDOOR',
  'state': {'id': 1, 'name': state},
  'isViable': true,
  'probability': 80,
  'probabilityBand': 'GREEN',
  'cancelReason': null,
  'weatherConditions': <dynamic>[],
  ...?(extra as Map<String, dynamic>?),
};

http.Response _ok(Map<String, dynamic> data) => http.Response(
  jsonEncode({'status': 200, 'message': 'ok', 'data': data}),
  200,
);

void main() {
  late List<http.Request> seen;

  ActivitiesRemoteDataSource build(http.Response Function() response) {
    seen = [];
    final client = ApiClient(
      client: MockClient((request) async {
        seen.add(request);
        return response();
      }),
    );
    return ActivitiesRemoteDataSource(client);
  }

  group('remote data source', () {
    test('complete PATCHes /complete and reads visitStatus', () async {
      final remote = build(
        () => _ok(
          _activityJson('completed', extra: {'visitStatus': 'COMPLETED'}),
        ),
      );

      final result = await remote.complete(5);

      expect(seen.single.method, 'PATCH');
      expect(seen.single.url.path, endsWith('/activities/5/complete'));
      expect(result.activity.state, ActivityState.completed);
      expect(result.visitStatus, VisitStatus.completed);
    });

    test('uncomplete PATCHes /uncomplete and reopens the visit', () async {
      final remote = build(
        () => _ok(_activityJson('planned', extra: {'visitStatus': 'PLANNED'})),
      );

      final result = await remote.uncomplete(5);

      expect(seen.single.url.path, endsWith('/activities/5/uncomplete'));
      expect(result.activity.state, ActivityState.planned);
      expect(result.visitStatus, VisitStatus.planned);
    });

    test('cancel sends the reason only when given', () async {
      final remote = build(
        () => _ok(_activityJson('cancelled', extra: {'cancelReason': 'x'})),
      );

      await remote.cancel(5, reason: 'Me enfermé');
      await remote.cancel(5);

      expect(jsonDecode(seen[0].body), {'reason': 'Me enfermé'});
      expect(jsonDecode(seen[1].body), isEmpty);
      expect(seen[0].url.path, endsWith('/activities/5/cancel'));
    });

    test('a missing visitStatus stays null', () async {
      final remote = build(() => _ok(_activityJson('cancelled')));

      final result = await remote.cancel(5);

      expect(result.visitStatus, isNull);
    });

    test('reactivate PATCHes /reactivate', () async {
      final remote = build(() => _ok(_activityJson('planned')));

      final activity = await remote.reactivate(5);

      expect(seen.single.url.path, endsWith('/activities/5/reactivate'));
      expect(activity.state, ActivityState.planned);
    });

    test('reschedule sends date and times', () async {
      final remote = build(() => _ok(_activityJson('planned')));

      await remote.reschedule(
        5,
        date: DateTime(2026, 11, 5),
        startTime: t('14:00'),
        endTime: t('16:00'),
      );

      expect(seen.single.url.path, endsWith('/activities/5/reschedule'));
      expect(jsonDecode(seen.single.body), {
        'date': '2026-11-05',
        'startTime': '14:00',
        'endTime': '16:00',
      });
    });

    test('API errors surface their message', () async {
      final remote = build(
        () => http.Response(
          jsonEncode({
            'status': 409,
            'message': "El horario se cruza con la actividad 'Almuerzo'",
          }),
          409,
        ),
      );

      await expectLater(
        remote.reschedule(
          5,
          date: DateTime(2026, 11, 5),
          startTime: t('14:00'),
          endTime: t('16:00'),
        ),
        throwsA(isA<ApiException>().having((e) => e.status, 'status', 409)),
      );
    });
  });

  group('use cases', () {
    test('complete and uncomplete delegate to the repository', () async {
      final repo = FakeActivitiesRepository([makeActivity(id: 5)]);

      final done = await CompleteActivity(repo)(5);
      final undone = await UncompleteActivity(repo)(5);

      expect(done.activity.state, ActivityState.completed);
      expect(undone.activity.state, ActivityState.planned);
      expect(repo.actions, ['complete:5', 'uncomplete:5']);
    });

    test('cancel trims the reason and drops a blank one', () async {
      final repo = FakeActivitiesRepository([makeActivity(id: 5)]);

      await CancelActivity(repo)(5, reason: '  Me enfermé  ');
      await CancelActivity(repo)(5, reason: '   ');

      expect(repo.actions, ['cancel:5:Me enfermé', 'cancel:5:']);
    });

    test('reactivate and reschedule delegate to the repository', () async {
      final repo = FakeActivitiesRepository([
        makeActivity(id: 5, state: ActivityState.cancelledBySystem),
      ]);

      final reactivated = await ReactivateActivity(repo)(5);
      await RescheduleActivity(repo)(
        5,
        date: DateTime(2026, 11, 5),
        startTime: t('14:00'),
        endTime: t('16:00'),
      );

      expect(reactivated.state, ActivityState.planned);
      expect(repo.rescheduled.single['date'], DateTime(2026, 11, 5));
    });

    test('the repository implementation forwards to the data source', () async {
      final remote = build(() => _ok(_activityJson('completed')));
      final repository = ActivitiesRepositoryImpl(remote);

      final result = await repository.complete(5);

      expect(result.activity.state, ActivityState.completed);
    });
  });
}
