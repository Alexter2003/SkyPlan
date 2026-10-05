import '../../domain/entities/weather_condition.dart';
import '../../domain/repositories/weather_conditions_repository.dart';
import '../datasources/weather_conditions_remote_datasource.dart';

/// El catálogo no cambia durante la sesión: se guarda tras la primera carga.
class WeatherConditionsRepositoryImpl implements WeatherConditionsRepository {
  WeatherConditionsRepositoryImpl(this._remote);

  final WeatherConditionsRemoteDataSource _remote;
  List<WeatherCondition>? _cache;

  @override
  Future<List<WeatherCondition>> getCatalog() async =>
      _cache ??= await _remote.getAll();
}
