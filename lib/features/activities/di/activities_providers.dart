import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../locations/domain/repositories/visits_repository.dart';
import '../data/datasources/activities_remote_datasource.dart';
import '../data/datasources/weather_conditions_remote_datasource.dart';
import '../data/repositories/activities_repository_impl.dart';
import '../data/repositories/weather_conditions_repository_impl.dart';
import '../domain/repositories/activities_repository.dart';
import '../domain/repositories/weather_conditions_repository.dart';
import '../domain/usecases/create_activity.dart';
import '../domain/usecases/delete_activity.dart';
import '../domain/usecases/get_activities_by_visit.dart';
import '../domain/usecases/get_activities_grouped_by_visit.dart';
import '../domain/usecases/get_weather_conditions.dart';
import '../domain/usecases/update_activity.dart';

/// Providers del módulo activities, compuestos por `core/di/app_providers.dart`.
final activitiesProviders = [
  Provider<ActivitiesRepository>(
    create: (context) => ActivitiesRepositoryImpl(
      ActivitiesRemoteDataSource(context.read<ApiClient>()),
    ),
  ),
  Provider<WeatherConditionsRepository>(
    create: (context) => WeatherConditionsRepositoryImpl(
      WeatherConditionsRemoteDataSource(context.read<ApiClient>()),
    ),
  ),
  Provider<GetActivitiesByVisit>(
    create: (context) =>
        GetActivitiesByVisit(context.read<ActivitiesRepository>()),
  ),
  Provider<GetActivitiesGroupedByVisit>(
    create: (context) => GetActivitiesGroupedByVisit(
      context.read<VisitsRepository>(),
      context.read<ActivitiesRepository>(),
    ),
  ),
  Provider<CreateActivity>(
    create: (context) => CreateActivity(context.read<ActivitiesRepository>()),
  ),
  Provider<UpdateActivity>(
    create: (context) => UpdateActivity(context.read<ActivitiesRepository>()),
  ),
  Provider<DeleteActivity>(
    create: (context) => DeleteActivity(context.read<ActivitiesRepository>()),
  ),
  Provider<GetWeatherConditions>(
    create: (context) =>
        GetWeatherConditions(context.read<WeatherConditionsRepository>()),
  ),
];
