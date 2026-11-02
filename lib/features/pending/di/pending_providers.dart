import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/upcoming_remote_datasource.dart';
import '../data/repositories/upcoming_repository_impl.dart';
import '../domain/repositories/upcoming_repository.dart';
import '../domain/usecases/get_upcoming_activities.dart';

/// Providers del módulo pending, compuestos por `core/di/app_providers.dart`.
final pendingProviders = [
  Provider<UpcomingRepository>(
    create: (context) => UpcomingRepositoryImpl(
      UpcomingRemoteDataSource(context.read<ApiClient>()),
    ),
  ),
  Provider<GetUpcomingActivities>(
    create: (context) =>
        GetUpcomingActivities(context.read<UpcomingRepository>()),
  ),
];
