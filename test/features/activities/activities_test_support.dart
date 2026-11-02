import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme_context.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';
import 'package:sky_plan/features/activities/domain/entities/activity_action_result.dart';
import 'package:sky_plan/features/locations/domain/entities/visit.dart';
import 'package:sky_plan/features/activities/domain/entities/time_of_day_value.dart';
import 'package:sky_plan/features/activities/domain/entities/weather_condition.dart';
import 'package:sky_plan/features/activities/domain/repositories/activities_repository.dart';
import 'package:sky_plan/features/activities/domain/repositories/weather_conditions_repository.dart';
import 'package:sky_plan/features/activities/domain/usecases/complete_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/create_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/delete_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/get_activities_by_visit.dart';
import 'package:sky_plan/features/activities/domain/usecases/get_activities_grouped_by_visit.dart';
import 'package:sky_plan/features/activities/domain/usecases/get_weather_conditions.dart';
import 'package:sky_plan/features/activities/domain/usecases/uncomplete_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/update_activity.dart';
import 'package:sky_plan/features/auth/domain/usecases/logout.dart';
import 'package:sky_plan/features/auth/presentation/state/session_controller.dart';
import 'package:sky_plan/features/locations/domain/repositories/visits_repository.dart';
import 'package:sky_plan/features/notifications/presentation/state/notifications_controller.dart';
import 'package:sky_plan/features/locations/domain/usecases/get_visits.dart';

import '../auth/auth_test_app.dart';
import '../auth/fake_auth_repository.dart';
import '../locations/locations_test_support.dart';
import '../notifications/notifications_test_support.dart';

TimeOfDayValue t(String value) => TimeOfDayValue.parse(value);

Activity makeActivity({
  int id = 1,
  int visitId = 1,
  String name = 'Caminata',
  String start = '09:00',
  String end = '11:00',
  ActivityType type = ActivityType.outdoor,
  ActivityState state = ActivityState.planned,
  bool? isViable = true,
  List<int> conditionIds = const [1],
  int? probability,
  ProbabilityBand? band,
  String? cancelReason,
}) {
  return Activity(
    id: id,
    visitId: visitId,
    name: name,
    description: 'Cerro de la Cruz',
    date: DateTime(2030, 1, 10),
    startTime: t(start),
    endTime: t(end),
    type: type,
    state: state,
    isViable: isViable,
    probability: probability,
    probabilityBand: band,
    cancelReason: cancelReason,
    conditions: [
      for (final c in conditionIds) ActivityCondition(id: c, name: 'c$c'),
    ],
  );
}

/// Catálogo reducido: sunny(1) choca con rainy(2); windy(3) es compatible con todo.
const testCatalog = [
  WeatherCondition(id: 1, name: 'sunny', description: '', conflictsWith: {2}),
  WeatherCondition(id: 2, name: 'rainy', description: '', conflictsWith: {1}),
  WeatherCondition(id: 3, name: 'windy', description: '', conflictsWith: {}),
];

class FakeActivitiesRepository implements ActivitiesRepository {
  FakeActivitiesRepository([List<Activity>? initial])
    : activities = [...?initial];

  List<Activity> activities;
  Object? error;
  final List<Map<String, Object?>> created = [];
  final List<Map<String, Object?>> updated = [];
  final List<int> deletedIds = [];
  final List<String> actions = [];

  /// `visitStatus` que devuelven complete/uncomplete/cancel.
  VisitStatus? nextVisitStatus;
  final List<Map<String, Object?>> rescheduled = [];

  Activity _replace(int id, Activity Function(Activity) change) {
    final index = activities.indexWhere((a) => a.id == id);
    final base = index >= 0 ? activities[index] : makeActivity(id: id);
    final next = change(base);
    if (index >= 0) activities[index] = next;
    return next;
  }

  Activity _copy(Activity a, {ActivityState? state, String? cancelReason}) =>
      Activity(
        id: a.id,
        visitId: a.visitId,
        name: a.name,
        description: a.description,
        date: a.date,
        startTime: a.startTime,
        endTime: a.endTime,
        type: a.type,
        state: state ?? a.state,
        conditions: a.conditions,
        isViable: a.isViable,
        probability: a.probability,
        probabilityBand: a.probabilityBand,
        cancelReason: cancelReason ?? a.cancelReason,
      );

  @override
  Future<ActivityActionResult> complete(int id) async {
    if (error != null) throw error!;
    actions.add('complete:$id');
    return ActivityActionResult(
      activity: _replace(id, (a) => _copy(a, state: ActivityState.completed)),
      visitStatus: nextVisitStatus,
    );
  }

  @override
  Future<ActivityActionResult> uncomplete(int id) async {
    if (error != null) throw error!;
    actions.add('uncomplete:$id');
    return ActivityActionResult(
      activity: _replace(id, (a) => _copy(a, state: ActivityState.planned)),
      visitStatus: nextVisitStatus,
    );
  }

  @override
  Future<ActivityActionResult> cancel(int id, {String? reason}) async {
    if (error != null) throw error!;
    actions.add('cancel:$id:${reason ?? ''}');
    return ActivityActionResult(
      activity: _replace(
        id,
        (a) => _copy(a, state: ActivityState.cancelled, cancelReason: reason),
      ),
    );
  }

  @override
  Future<Activity> reactivate(int id) async {
    if (error != null) throw error!;
    actions.add('reactivate:$id');
    return _replace(id, (a) => _copy(a, state: ActivityState.planned));
  }

  @override
  Future<Activity> reschedule(
    int id, {
    required DateTime date,
    required TimeOfDayValue startTime,
    required TimeOfDayValue endTime,
  }) async {
    if (error != null) throw error!;
    rescheduled.add({
      'id': id,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    });
    return _replace(id, (a) => _copy(a, state: ActivityState.planned));
  }

  @override
  Future<List<Activity>> getByVisit(int visitId) async {
    if (error != null) throw error!;
    return activities.where((a) => a.visitId == visitId).toList();
  }

  @override
  Future<Activity> create({
    required int visitId,
    required String name,
    required String description,
    required TimeOfDayValue startTime,
    required TimeOfDayValue endTime,
    required ActivityType type,
    required List<int> weatherConditionIds,
  }) async {
    if (error != null) throw error!;
    created.add({
      'visitId': visitId,
      'name': name,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
      'weatherConditionIds': weatherConditionIds,
    });
    return makeActivity(id: 99, visitId: visitId, name: name);
  }

  @override
  Future<Activity> update(
    int id, {
    String? name,
    String? description,
    TimeOfDayValue? startTime,
    TimeOfDayValue? endTime,
    ActivityType? type,
    List<int>? weatherConditionIds,
  }) async {
    if (error != null) throw error!;
    updated.add({
      'id': id,
      'name': name,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
      'weatherConditionIds': weatherConditionIds,
    });
    return makeActivity(id: id, name: name ?? 'x');
  }

  @override
  Future<void> delete(int id) async {
    if (error != null) throw error!;
    deletedIds.add(id);
    activities = activities.where((a) => a.id != id).toList();
  }
}

class FakeWeatherConditionsRepository implements WeatherConditionsRepository {
  @override
  Future<List<WeatherCondition>> getCatalog() async => testCatalog;
}

/// App de prueba con los providers de locations y activities.
Widget buildActivitiesTestApp({
  required FakeVisitsRepository visits,
  required FakeActivitiesRepository activities,
  required Widget child,
}) {
  return SkyThemeScope(
    controller: SkyThemeController(),
    child: MultiProvider(
      providers: [
        Provider<VisitsRepository>.value(value: visits),
        Provider<ActivitiesRepository>.value(value: activities),
        Provider<WeatherConditionsRepository>.value(
          value: FakeWeatherConditionsRepository(),
        ),
        Provider<GetVisits>(create: (c) => GetVisits(c.read())),
        Provider<GetActivitiesByVisit>(
          create: (c) => GetActivitiesByVisit(c.read()),
        ),
        Provider<GetActivitiesGroupedByVisit>(
          create: (c) => GetActivitiesGroupedByVisit(c.read(), c.read()),
        ),
        Provider<CreateActivity>(create: (c) => CreateActivity(c.read())),
        Provider<UpdateActivity>(create: (c) => UpdateActivity(c.read())),
        Provider<DeleteActivity>(create: (c) => DeleteActivity(c.read())),
        Provider<CompleteActivity>(create: (c) => CompleteActivity(c.read())),
        Provider<UncompleteActivity>(
          create: (c) => UncompleteActivity(c.read()),
        ),
        Provider<GetWeatherConditions>(
          create: (c) => GetWeatherConditions(c.read()),
        ),
        Provider<Logout>(create: (_) => Logout(FakeAuthRepository())),
        ChangeNotifierProvider<SessionController>(
          create: (c) => SessionController(
            storage: InMemorySessionStorage(),
            logout: c.read(),
          ),
        ),
        ChangeNotifierProvider<NotificationsController>(
          create: (c) => NotificationsController(
            session: c.read(),
            repository: FakeNotificationsRepository(),
            realtime: FakeRealtimeSource(),
            notifier: FakeLocalNotifier(),
          ),
        ),
      ],
      child: MaterialApp(
        theme: SkyTheme.light,
        home: child,
        routes: {
          '/login': (_) => const Scaffold(body: Text('route:login')),
          '/home': (_) => const Scaffold(body: Text('route:home')),
          '/locations': (_) => const Scaffold(body: Text('route:locations')),
          '/activities': (_) => const Scaffold(body: Text('route:activities')),
        },
      ),
    ),
  );
}
