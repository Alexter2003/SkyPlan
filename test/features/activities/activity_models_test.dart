import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/features/activities/data/models/activity_model.dart';
import 'package:sky_plan/features/activities/data/models/weather_condition_model.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';

void main() {
  test('ActivityModel parses the API object', () {
    final model = ActivityModel.fromJson({
      'id': 5,
      'visitId': 10,
      'name': 'Caminata',
      'description': 'Cerro de la Cruz',
      'date': '2026-10-05',
      'startTime': '09:00',
      'endTime': '11:00',
      'type': 'OUTDOOR',
      'state': {'id': 1, 'name': 'planned'},
      'isViable': null,
      'viabilityCheckedAt': null,
      'completedAt': null,
      'weatherConditions': [
        {'id': 1, 'name': 'sunny'},
      ],
    });

    expect(model.date, DateTime(2026, 10, 5));
    expect(model.startTime.format(), '09:00');
    expect(model.type, ActivityType.outdoor);
    expect(model.state, ActivityState.planned);
    expect(model.isViable, isNull);
    expect(model.isPendingValidation, isTrue);
    expect(model.conditionIds, {1});
  });

  test('needsAttention only for planned activities that are not viable', () {
    final base = {
      'id': 1,
      'visitId': 1,
      'name': 'x',
      'description': '',
      'date': '2026-10-05',
      'startTime': '09:00',
      'endTime': '10:00',
      'type': 'OUTDOOR',
      'weatherConditions': <dynamic>[],
    };
    final planned = ActivityModel.fromJson({
      ...base,
      'isViable': false,
      'state': {'id': 1, 'name': 'planned'},
    });
    final cancelled = ActivityModel.fromJson({
      ...base,
      'isViable': false,
      'state': {'id': 3, 'name': 'cancelled'},
    });

    expect(planned.needsAttention, isTrue);
    expect(cancelled.needsAttention, isFalse);
  });

  test('WeatherConditionModel parses conflictsWith', () {
    final model = WeatherConditionModel.fromJson({
      'id': 1,
      'name': 'sunny',
      'description': 'Clear sky',
      'conflictsWith': [2, 3],
    });

    expect(model.conflictsWith, {2, 3});
  });
}
