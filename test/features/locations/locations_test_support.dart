import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme.dart';
import 'package:sky_plan/core/design_system/theme/sky_theme_context.dart';
import 'package:sky_plan/features/auth/domain/usecases/logout.dart';
import 'package:sky_plan/features/auth/presentation/state/session_controller.dart';
import 'package:sky_plan/features/locations/domain/entities/geo_point.dart';
import 'package:sky_plan/features/locations/domain/entities/visit.dart';
import 'package:sky_plan/features/locations/domain/entities/visit_weather.dart';
import 'package:sky_plan/features/locations/domain/repositories/device_location_repository.dart';
import 'package:sky_plan/features/locations/domain/repositories/visits_repository.dart';
import 'package:sky_plan/features/locations/domain/usecases/cancel_visit.dart';
import 'package:sky_plan/features/locations/domain/usecases/complete_visit.dart';
import 'package:sky_plan/features/locations/domain/usecases/create_visit.dart';
import 'package:sky_plan/features/locations/domain/usecases/delete_visit.dart';
import 'package:sky_plan/features/locations/domain/usecases/get_current_position.dart';
import 'package:sky_plan/features/locations/domain/usecases/get_visits.dart';
import 'package:sky_plan/features/locations/domain/usecases/open_location_settings.dart';
import 'package:sky_plan/features/locations/domain/usecases/update_visit.dart';

import '../auth/auth_test_app.dart';
import '../auth/fake_auth_repository.dart';

Visit makeVisit({
  int id = 1,
  String name = 'Antigua Guatemala',
  DateTime? date,
  VisitStatus status = VisitStatus.planned,
  bool withWeather = true,
}) {
  return Visit(
    id: id,
    name: name,
    point: const GeoPoint(latitude: 14.5586, longitude: -90.7295),
    date: date ?? DateTime(2030, 1, 10),
    status: status,
    createdAt: DateTime(2026, 1, 1),
    weather: withWeather
        ? VisitWeather(
            temperature: 22.4,
            precipitation: 0.2,
            humidity: 71,
            atmosphericPressure: 1013.4,
            updatedAt: DateTime(2026, 1, 1),
          )
        : null,
  );
}

/// Doble en memoria de [VisitsRepository].
class FakeVisitsRepository implements VisitsRepository {
  FakeVisitsRepository([List<Visit>? initial]) : visits = [...?initial];

  List<Visit> visits;
  Object? error;
  final List<int> deletedIds = [];
  final List<int> completedIds = [];
  final List<int> cancelledIds = [];
  final List<Map<String, Object?>> created = [];
  final List<Map<String, Object?>> updated = [];

  @override
  Future<List<Visit>> getVisits() async {
    if (error != null) throw error!;
    return [...visits];
  }

  @override
  Future<Visit> createVisit({
    required String name,
    required GeoPoint point,
    required DateTime date,
  }) async {
    if (error != null) throw error!;
    created.add({'name': name, 'point': point, 'date': date});
    return makeVisit(id: 99, name: name, date: date, withWeather: false);
  }

  @override
  Future<Visit> updateVisit(
    int id, {
    String? name,
    GeoPoint? point,
    DateTime? date,
  }) async {
    if (error != null) throw error!;
    updated.add({'id': id, 'name': name, 'point': point, 'date': date});
    return makeVisit(id: id, name: name ?? 'x');
  }

  @override
  Future<Visit> completeVisit(int id) async {
    if (error != null) throw error!;
    completedIds.add(id);
    return _withStatus(id, VisitStatus.completed);
  }

  @override
  Future<Visit> cancelVisit(int id) async {
    if (error != null) throw error!;
    cancelledIds.add(id);
    return _withStatus(id, VisitStatus.cancelled);
  }

  @override
  Future<void> deleteVisit(int id) async {
    if (error != null) throw error!;
    deletedIds.add(id);
    visits = visits.where((v) => v.id != id).toList();
  }

  Visit _withStatus(int id, VisitStatus status) {
    final v = visits.firstWhere((v) => v.id == id);
    return makeVisit(id: v.id, name: v.name, date: v.date, status: status);
  }
}

/// Doble de [DeviceLocationRepository]: devuelve un punto o lanza [error].
class FakeDeviceLocationRepository implements DeviceLocationRepository {
  Object? error;
  GeoPoint point = const GeoPoint(latitude: 14.6, longitude: -90.5);
  int settingsOpened = 0;

  @override
  Future<GeoPoint> getCurrentPosition() async {
    if (error != null) throw error!;
    return point;
  }

  @override
  Future<void> openLocationSettings() async => settingsOpened++;

  @override
  Future<void> openAppSettings() async => settingsOpened++;
}

/// App de prueba con los providers del módulo locations.
Widget buildLocationsTestApp({
  required FakeVisitsRepository visits,
  required Widget child,
  FakeDeviceLocationRepository? device,
}) {
  final deviceRepo = device ?? FakeDeviceLocationRepository();
  return SkyThemeScope(
    controller: SkyThemeController(),
    child: MultiProvider(
      providers: [
        Provider<VisitsRepository>.value(value: visits),
        Provider<DeviceLocationRepository>.value(value: deviceRepo),
        Provider<GetVisits>(create: (c) => GetVisits(c.read())),
        Provider<CreateVisit>(create: (c) => CreateVisit(c.read())),
        Provider<UpdateVisit>(create: (c) => UpdateVisit(c.read())),
        Provider<CompleteVisit>(create: (c) => CompleteVisit(c.read())),
        Provider<CancelVisit>(create: (c) => CancelVisit(c.read())),
        Provider<DeleteVisit>(create: (c) => DeleteVisit(c.read())),
        Provider<GetCurrentPosition>(
          create: (c) => GetCurrentPosition(c.read()),
        ),
        Provider<OpenLocationSettings>(
          create: (c) => OpenLocationSettings(c.read()),
        ),
        Provider<Logout>(create: (_) => Logout(FakeAuthRepository())),
        ChangeNotifierProvider<SessionController>(
          create: (c) => SessionController(
            storage: InMemorySessionStorage(),
            logout: c.read(),
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
        },
      ),
    ),
  );
}
