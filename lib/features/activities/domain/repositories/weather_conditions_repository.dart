import '../entities/weather_condition.dart';

abstract class WeatherConditionsRepository {
  Future<List<WeatherCondition>> getCatalog();
}
