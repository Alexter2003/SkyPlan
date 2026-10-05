import '../../domain/entities/weather_condition.dart';

class WeatherConditionModel extends WeatherCondition {
  const WeatherConditionModel({
    required super.id,
    required super.name,
    required super.description,
    required super.conflictsWith,
  });

  factory WeatherConditionModel.fromJson(Map<String, dynamic> json) {
    return WeatherConditionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      conflictsWith: {
        for (final id in json['conflictsWith'] as List<dynamic>? ?? const [])
          id as int,
      },
    );
  }
}
