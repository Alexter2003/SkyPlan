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

  group('state and probability parsing', () {
    Map<String, dynamic> json(
      String state, {
      Object? probability,
      Object? band,
    }) => {
      'id': 1,
      'visitId': 1,
      'name': 'x',
      'description': '',
      'date': '2026-10-05',
      'startTime': '09:00',
      'endTime': '10:00',
      'type': 'OUTDOOR',
      'state': {'id': 1, 'name': state},
      'probability': probability,
      'probabilityBand': band,
      'weatherConditions': <dynamic>[],
    };

    test('maps each of the four API states', () {
      expect(
        ActivityModel.fromJson(json('planned')).state,
        ActivityState.planned,
      );
      expect(
        ActivityModel.fromJson(json('completed')).state,
        ActivityState.completed,
      );
      expect(
        ActivityModel.fromJson(json('cancelled')).state,
        ActivityState.cancelled,
      );
      expect(
        ActivityModel.fromJson(json('cancelled_by_system')).state,
        ActivityState.cancelledBySystem,
      );
    });

    test('a system cancellation is cancelled but not planned', () {
      final activity = ActivityModel.fromJson(json('cancelled_by_system'));

      expect(activity.isCancelled, isTrue);
      expect(activity.isEditable, isFalse);
    });

    test('parses probability and the traffic-light band', () {
      final green = ActivityModel.fromJson(
        json('planned', probability: 80, band: 'GREEN'),
      );
      final yellow = ActivityModel.fromJson(
        json('planned', probability: 55, band: 'YELLOW'),
      );
      final red = ActivityModel.fromJson(
        json('planned', probability: 10, band: 'RED'),
      );

      expect(green.probability, 80);
      expect(green.probabilityBand, ProbabilityBand.green);
      expect(yellow.probabilityBand, ProbabilityBand.yellow);
      expect(red.probabilityBand, ProbabilityBand.red);
    });

    test('null probability stays null, never invented', () {
      final activity = ActivityModel.fromJson(json('planned'));

      expect(activity.probability, isNull);
      expect(activity.probabilityBand, isNull);
    });

    test('parses cancellation reason and timestamps', () {
      final activity = ActivityModel.fromJson({
        ...json('cancelled_by_system'),
        'cancelReason': 'Cancelada automáticamente',
        'cancelledAt': '2026-11-03T20:45:00.000Z',
        'completedAt': null,
      });

      expect(activity.cancelReason, 'Cancelada automáticamente');
      expect(activity.cancelledAt, DateTime.utc(2026, 11, 3, 20, 45));
      expect(activity.completedAt, isNull);
    });
  });
}
