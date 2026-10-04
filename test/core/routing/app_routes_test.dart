import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/core/routing/app_routes.dart';
import 'package:sky_plan/features/locations/domain/entities/geo_point.dart';
import 'package:sky_plan/features/locations/domain/entities/visit.dart';

void main() {
  // `pushNamed<T>` castea la ruta a `Route<T>`: deben estar tipadas.
  test('location form route is typed to return a Visit', () {
    final route = AppRoutes.onGenerateRoute(
      const RouteSettings(
        name: AppRoutes.locationForm,
        arguments: LocationFormArgs(),
      ),
    );

    expect(route, isA<Route<Visit>>());
  });

  test('map picker route is typed to return a GeoPoint', () {
    final route = AppRoutes.onGenerateRoute(
      const RouteSettings(
        name: AppRoutes.mapPicker,
        arguments: MapPickerArgs(),
      ),
    );

    expect(route, isA<Route<GeoPoint>>());
  });
}
