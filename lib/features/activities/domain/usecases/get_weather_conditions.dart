import '../entities/weather_condition.dart';
import '../repositories/weather_conditions_repository.dart';

class GetWeatherConditions {
  const GetWeatherConditions(this._repository);

  final WeatherConditionsRepository _repository;

  Future<List<WeatherCondition>> call() => _repository.getCatalog();
}
