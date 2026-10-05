import '../../../../core/network/api_client.dart';
import '../models/weather_condition_model.dart';

/// Llamada HTTP de `/weather-conditions`.
class WeatherConditionsRemoteDataSource {
  const WeatherConditionsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<WeatherConditionModel>> getAll() async {
    final envelope = await _client.getJson('/weather-conditions');
    final data = envelope.data;
    if (data is! List) return const [];
    return data
        .cast<Map<String, dynamic>>()
        .map(WeatherConditionModel.fromJson)
        .toList();
  }
}
