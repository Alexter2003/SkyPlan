import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/features/locations/data/models/visit_model.dart';
import 'package:sky_plan/features/locations/domain/entities/visit.dart';

Map<String, dynamic> _json({Map<String, dynamic>? overrides}) => {
  'id': 10,
  'name': 'Antigua Guatemala',
  'latitude': 14.5586,
  'longitude': -90.7295,
  'date': '2026-09-28',
  'status': 'PLANNED',
  'temperature': 22.4,
  'precipitation': 0,
  'humidity': 71,
  'atmosphericPressure': 1013.4,
  'weatherUpdate': '2026-09-20T12:00:00.000Z',
  'createdAt': '2026-09-20T12:00:00.000Z',
  ...?overrides,
};

void main() {
  test('parses a full visit with weather (ints accepted as numbers)', () {
    final visit = VisitModel.fromJson(_json());

    expect(visit.id, 10);
    expect(visit.point.latitude, 14.5586);
    expect(visit.date, DateTime(2026, 9, 28));
    expect(visit.status, VisitStatus.planned);
    expect(visit.weather?.temperature, 22.4);
    expect(visit.weather?.precipitation, 0);
    expect(visit.weather?.humidity, 71);
  });

  test('weather is null when the forecast fields are null', () {
    final visit = VisitModel.fromJson(
      _json(
        overrides: {
          'temperature': null,
          'precipitation': null,
          'humidity': null,
          'atmosphericPressure': null,
          'weatherUpdate': null,
        },
      ),
    );

    expect(visit.weather, isNull);
  });

  test('maps COMPLETED and CANCELLED statuses', () {
    expect(
      VisitModel.fromJson(_json(overrides: {'status': 'COMPLETED'})).status,
      VisitStatus.completed,
    );
    expect(
      VisitModel.fromJson(_json(overrides: {'status': 'CANCELLED'})).status,
      VisitStatus.cancelled,
    );
  });

  test('formats and parses API dates without time zone shifts', () {
    expect(VisitModel.formatApiDate(DateTime(2026, 1, 5)), '2026-01-05');
    expect(VisitModel.parseApiDate('2026-01-05'), DateTime(2026, 1, 5));
  });
}
