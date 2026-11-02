import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme_context.dart';
import 'package:sky_plan/features/activities/domain/entities/activity.dart';
import 'package:sky_plan/features/activities/domain/repositories/activities_repository.dart';
import 'package:sky_plan/features/activities/domain/usecases/cancel_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/complete_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/reactivate_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/reschedule_activity.dart';
import 'package:sky_plan/features/activities/domain/usecases/uncomplete_activity.dart';
import 'package:sky_plan/features/auth/domain/usecases/logout.dart';
import 'package:sky_plan/features/auth/presentation/state/session_controller.dart';
import 'package:sky_plan/features/locations/domain/repositories/visits_repository.dart';
import 'package:sky_plan/features/locations/domain/usecases/get_visits.dart';
import 'package:sky_plan/features/notifications/presentation/state/notifications_controller.dart';
import 'package:sky_plan/features/pending/domain/usecases/get_upcoming_activities.dart';
import 'package:sky_plan/features/locations/domain/entities/visit.dart';
import 'package:sky_plan/features/pending/domain/entities/upcoming_activity.dart';
import 'package:sky_plan/features/pending/domain/entities/upcoming_filters.dart';
import 'package:sky_plan/features/pending/domain/entities/upcoming_page.dart';
import 'package:sky_plan/features/pending/domain/entities/upcoming_visit.dart';
import 'package:sky_plan/features/pending/domain/repositories/upcoming_repository.dart';

import '../activities/activities_test_support.dart';
import '../auth/auth_test_app.dart';
import '../auth/fake_auth_repository.dart';
import '../locations/locations_test_support.dart';
import '../notifications/notifications_test_support.dart';

UpcomingVisit makeUpcomingVisit({
  int id = 1,
  String name = 'Antigua Guatemala',
  VisitStatus status = VisitStatus.planned,
}) => UpcomingVisit(
  id: id,
  name: name,
  latitude: 14.55,
  longitude: -90.72,
  date: DateTime(2030, 1, 10),
  status: status,
);

UpcomingActivity makeUpcoming({
  int id = 1,
  int visitId = 1,
  String name = 'Caminata',
  ActivityState state = ActivityState.planned,
  int? probability = 80,
  ProbabilityBand? band = ProbabilityBand.green,
  ActivityType type = ActivityType.outdoor,
  String? cancelReason,
}) => UpcomingActivity(
  activity: makeActivity(
    id: id,
    visitId: visitId,
    name: name,
    state: state,
    probability: probability,
    band: band,
    type: type,
    cancelReason: cancelReason,
  ),
  visit: makeUpcomingVisit(id: visitId),
);

/// Doble de prueba: filtra en memoria igual que lo haría el backend.
class FakeUpcomingRepository implements UpcomingRepository {
  FakeUpcomingRepository([List<UpcomingActivity>? initial])
    : items = [...?initial];

  List<UpcomingActivity> items;
  Object? error;
  final List<UpcomingFilters> requests = [];

  @override
  Future<UpcomingPage> getUpcoming(UpcomingFilters filters) async {
    requests.add(filters);
    if (error != null) throw error!;
    final result = items.where((i) {
      if (filters.visitId != null && i.visit.id != filters.visitId) {
        return false;
      }
      if (filters.state != null && i.activity.state != filters.state) {
        return false;
      }
      final p = i.activity.probability;
      if (filters.filtersByProbability && p == null) return false;
      if (filters.probabilityMin != null && p! < filters.probabilityMin!) {
        return false;
      }
      if (filters.probabilityMax != null && p! > filters.probabilityMax!) {
        return false;
      }
      return true;
    }).toList();
    return UpcomingPage(
      items: result,
      page: 1,
      limit: filters.limit,
      total: result.length,
    );
  }
}

/// App de prueba con los providers del módulo pending.
Widget buildPendingTestApp({
  required FakeUpcomingRepository upcoming,
  required FakeActivitiesRepository activities,
  required Widget child,
  FakeVisitsRepository? visits,
  NotificationsController? notifications,
}) {
  return SkyThemeScope(
    controller: SkyThemeController(),
    child: MultiProvider(
      providers: [
        Provider<ActivitiesRepository>.value(value: activities),
        Provider<VisitsRepository>.value(
          value: visits ?? FakeVisitsRepository(),
        ),
        Provider<GetVisits>(create: (c) => GetVisits(c.read())),
        Provider<GetUpcomingActivities>(
          create: (_) => GetUpcomingActivities(upcoming),
        ),
        Provider<CompleteActivity>(create: (c) => CompleteActivity(c.read())),
        Provider<UncompleteActivity>(
          create: (c) => UncompleteActivity(c.read()),
        ),
        Provider<CancelActivity>(create: (c) => CancelActivity(c.read())),
        Provider<ReactivateActivity>(
          create: (c) => ReactivateActivity(c.read()),
        ),
        Provider<RescheduleActivity>(
          create: (c) => RescheduleActivity(c.read()),
        ),
        Provider<Logout>(create: (_) => Logout(FakeAuthRepository())),
        ChangeNotifierProvider<SessionController>(
          create: (c) => SessionController(
            storage: InMemorySessionStorage(),
            logout: c.read(),
          ),
        ),
        ChangeNotifierProvider<NotificationsController>(
          create: (c) =>
              notifications ??
              NotificationsController(
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
        },
      ),
    ),
  );
}
