import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sky_plan/core/network/api_client.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';
import 'package:sky_plan/features/locations/domain/entities/visit.dart';
import 'package:sky_plan/features/pending/data/datasources/upcoming_remote_datasource.dart';
import 'package:sky_plan/features/pending/domain/entities/upcoming_filters.dart';

Map<String, dynamic> _item({Object? forecast}) => {
  'id': 5,
  'visitId': 10,
  'name': 'Caminata',
  'description': 'Cerro de la Cruz',
  'date': '2026-11-03',
  'startTime': '15:00',
  'endTime': '17:00',
  'type': 'OUTDOOR',
  'state': {'id': 1, 'name': 'planned'},
  'isViable': true,
  'probability': 80,
  'probabilityBand': 'GREEN',
  'weatherConditions': [
    {'id': 1, 'name': 'sunny'},
  ],
  'visit': {
    'id': 10,
    'name': 'Antigua Guatemala',
    'latitude': 14.5586,
    'longitude': -90.7295,
    'date': '2026-11-03',
    'status': 'PLANNED',
  },
  'forecast': forecast,
};

void main() {
  group('query building', () {
    test('default filters only carry sort and limit', () {
      expect(UpcomingRemoteDataSource.query(const UpcomingFilters()), {
        'sortBy': 'date',
        'order': 'asc',
        'limit': '100',
      });
    });

    test('all active filters are combined in one query', () {
      final query = UpcomingRemoteDataSource.query(
        const UpcomingFilters(
          days: 7,
          visitId: 10,
          probabilityMin: 40,
          probabilityMax: 90,
          state: ActivityState.cancelledBySystem,
          sortBy: UpcomingSort.probability,
          ascending: false,
        ),
      );

      expect(query, {
        'days': '7',
        'visitId': '10',
        'probabilityMin': '40',
        'probabilityMax': '90',
        'state': 'cancelled_by_system',
        'sortBy': 'probability',
        'order': 'desc',
        'limit': '100',
      });
    });
  });

  group('filters', () {
    test('copyWith can clear a single criterion', () {
      const filters = UpcomingFilters(days: 7, visitId: 3);

      final cleared = filters.copyWith(visitId: null);

      expect(cleared.visitId, isNull);
      expect(cleared.days, 7);
    });

    test('cleared keeps sorting but drops every criterion', () {
      const filters = UpcomingFilters(
        days: 7,
        probabilityMin: 40,
        sortBy: UpcomingSort.probability,
      );

      final cleared = filters.cleared();

      expect(cleared.isActive, isFalse);
      expect(cleared.sortBy, UpcomingSort.probability);
    });

    test('a probability range excludes unknown probabilities', () {
      expect(const UpcomingFilters().filtersByProbability, isFalse);
      expect(
        const UpcomingFilters(probabilityMax: 50).filtersByProbability,
        isTrue,
      );
    });
  });

  group('remote data source', () {
    test('requests /activities/upcoming and parses the page', () async {
      late http.Request seen;
      final remote = UpcomingRemoteDataSource(
        ApiClient(
          client: MockClient((request) async {
            seen = request;
            return http.Response(
              jsonEncode({
                'status': 200,
                'message': 'ok',
                'data': {
                  'items': [
                    _item(
                      forecast: [
                        {
                          'time': '2026-11-03T15:00',
                          'weatherCode': 0,
                          'precipitation': 0,
                          'cloudCover': 5,
                          'windSpeed': 5,
                          'precipitationProbability': 10,
                        },
                      ],
                    ),
                    _item(),
                  ],
                  'page': 1,
                  'limit': 20,
                  'total': 2,
                },
              }),
              200,
            );
          }),
        ),
      );

      final page = await remote.getUpcoming(
        const UpcomingFilters(days: 7, probabilityMin: 40),
      );

      expect(seen.url.path, endsWith('/activities/upcoming'));
      expect(seen.url.queryParameters['days'], '7');
      expect(seen.url.queryParameters['probabilityMin'], '40');
      expect(page.total, 2);
      expect(page.items.first.visit.name, 'Antigua Guatemala');
      expect(page.items.first.visit.status, VisitStatus.planned);
      expect(page.items.first.activity.probabilityBand, ProbabilityBand.green);
      expect(page.items.first.forecast!.single.hourLabel, '15:00');
      expect(page.items.first.forecast!.single.precipitationProbability, 10);
      expect(page.items.last.forecast, isNull);
    });

    test('hasMore is true when the server holds more than the page', () async {
      final remote = UpcomingRemoteDataSource(
        ApiClient(
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'status': 200,
                'message': 'ok',
                'data': {
                  'items': [_item()],
                  'page': 1,
                  'limit': 1,
                  'total': 5,
                },
              }),
              200,
            ),
          ),
        ),
      );

      final page = await remote.getUpcoming(const UpcomingFilters(limit: 1));

      expect(page.hasMore, isTrue);
    });
  });
}
