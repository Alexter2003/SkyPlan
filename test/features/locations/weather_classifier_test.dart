import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sky_plan/features/locations/domain/entities/visit_weather.dart';
import 'package:sky_plan/features/locations/domain/services/weather_classifier.dart';
import 'package:sky_plan/features/locations/presentation/widgets/visit_weather_panel.dart';

import '../auth/auth_test_app.dart';
import '../locations/locations_test_support.dart';

Set<String> _c(double cloud, double rain, double wind, int code) =>
    classifyWeather(
      cloudCover: cloud,
      precipitation: rain,
      windSpeed: wind,
      weatherCode: code,
    );

void main() {
  group('classifyWeather (casos de la guía)', () {
    test('clear sky', () {
      expect(_c(5, 0, 8, 0), {'sunny', 'clear'});
    });
    test('clear sky with wind', () {
      expect(_c(10, 0, 30, 0), {'sunny', 'clear', 'windy'});
    });
    test('partly cloudy', () {
      expect(_c(50, 0, 5, 2), {'partly_cloudy'});
    });
    test('drizzle and cloudy', () {
      expect(_c(99, 0.1, 9.6, 51), {'drizzle', 'cloudy'});
    });
    test('drizzle by precipitation and partly cloudy', () {
      expect(_c(60, 0.7, 5, 3), {'drizzle', 'partly_cloudy'});
    });
    test('rain and cloudy', () {
      expect(_c(95, 4.2, 8, 63), {'rainy', 'cloudy'});
    });
    test('rain by weather code never shows sun', () {
      expect(_c(10, 0, 5, 80), {'rainy'});
    });
    test('snow wins over rain', () {
      expect(_c(80, 2, 5, 73), {'snowy', 'cloudy'});
    });
  });

  group('VisitWeatherPanel', () {
    Future<void> pumpPanel(WidgetTester tester, VisitWeather? weather) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(
        buildLocationsTestApp(
          visits: FakeVisitsRepository(),
          child: Scaffold(
            body: SingleChildScrollView(
              child: VisitWeatherPanel(weather: weather),
            ),
          ),
        ),
      );
    }

    testWidgets('explains a drizzly day in plain words, never "Soleado"', (
      tester,
    ) async {
      await pumpPanel(
        tester,
        VisitWeather(
          temperature: 17,
          precipitation: 0.7,
          humidity: 78,
          atmosphericPressure: 1010,
          updatedAt: DateTime(2026, 10, 4, 12),
          cloudCover: 99,
          windSpeed: 6.7,
          weatherCode: 51,
        ),
      );

      expect(find.text('17 °C'), findsOneWidget);
      expect(find.text('Fresco'), findsOneWidget);
      expect(find.text('Llovizna'), findsOneWidget);
      expect(find.text('Nublado'), findsOneWidget);
      expect(find.text('Viento suave'), findsOneWidget);
      expect(find.text('Soleado'), findsNothing);
      expect(find.textContaining('mm'), findsNothing);
      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('km/h'), findsNothing);
    });

    testWidgets('describes strong wind and a clear dry day', (tester) async {
      await pumpPanel(
        tester,
        VisitWeather(
          temperature: 24,
          precipitation: 0,
          humidity: 50,
          atmosphericPressure: 1010,
          updatedAt: DateTime(2026, 10, 4, 12),
          cloudCover: 10,
          windSpeed: 35,
          weatherCode: 0,
        ),
      );

      expect(find.text('Despejado'), findsOneWidget);
      expect(find.text('Viento fuerte'), findsOneWidget);
      expect(find.text('Sin lluvia'), findsOneWidget);
    });

    testWidgets('incomplete forecast is pending, not classified', (
      tester,
    ) async {
      await pumpPanel(
        tester,
        VisitWeather(
          temperature: 22,
          precipitation: 0,
          humidity: 70,
          atmosphericPressure: 1010,
          updatedAt: DateTime(2026, 10, 4, 12),
        ),
      );

      expect(find.text('Clima pendiente'), findsOneWidget);
      expect(find.text('Soleado'), findsNothing);
      expect(find.text('22 °C'), findsOneWidget);
    });

    testWidgets('no forecast shows pending', (tester) async {
      await pumpPanel(tester, null);

      expect(find.text('Clima pendiente'), findsOneWidget);
    });
  });
}
