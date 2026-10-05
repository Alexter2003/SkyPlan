import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';
import 'package:sky_plan/features/activities/domain/entities/weather_condition.dart';
import 'package:sky_plan/features/activities/domain/services/condition_rules.dart';
import 'package:sky_plan/features/activities/domain/services/schedule_rules.dart';

import 'activities_test_support.dart';

void main() {
  group('findOverlap', () {
    final existing = [
      makeActivity(id: 1, name: 'Almuerzo', start: '10:00', end: '12:00'),
    ];

    test('detects a crossing range', () {
      final overlap = findOverlap(
        start: t('11:00'),
        end: t('13:00'),
        existing: existing,
      );
      expect(overlap?.name, 'Almuerzo');
    });

    test('back-to-back activities do not cross', () {
      expect(
        findOverlap(start: t('12:00'), end: t('13:00'), existing: existing),
        isNull,
      );
      expect(
        findOverlap(start: t('09:00'), end: t('10:00'), existing: existing),
        isNull,
      );
    });

    test('cancelled activities do not occupy time', () {
      final cancelled = [
        makeActivity(
          start: '10:00',
          end: '12:00',
          state: ActivityState.cancelled,
        ),
      ];
      expect(
        findOverlap(start: t('10:30'), end: t('11:00'), existing: cancelled),
        isNull,
      );
    });

    test('excludes the activity being edited', () {
      expect(
        findOverlap(
          start: t('10:00'),
          end: t('12:00'),
          existing: existing,
          excludeId: 1,
        ),
        isNull,
      );
    });
  });

  test('isValidRange requires start before end', () {
    expect(isValidRange(t('09:00'), t('10:00')), isTrue);
    expect(isValidRange(t('10:00'), t('10:00')), isFalse);
    expect(isValidRange(t('11:00'), t('10:00')), isFalse);
  });

  group('blockedConditionIds', () {
    test('nothing selected blocks nothing', () {
      expect(blockedConditionIds({}, testCatalog), isEmpty);
    });

    test('selecting sunny blocks rainy and keeps windy available', () {
      expect(blockedConditionIds({1}, testCatalog), {2});
    });

    test('conflicts are symmetric even if only one side declares them', () {
      const onlyOneSide = [
        WeatherCondition(
          id: 1,
          name: 'sunny',
          description: '',
          conflictsWith: {2},
        ),
        WeatherCondition(
          id: 2,
          name: 'rainy',
          description: '',
          conflictsWith: {},
        ),
      ];
      expect(blockedConditionIds({2}, onlyOneSide), {1});
    });
  });
}
