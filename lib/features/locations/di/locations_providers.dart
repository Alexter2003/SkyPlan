import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/device_location_datasource.dart';
import '../data/datasources/visits_remote_datasource.dart';
import '../data/repositories/device_location_repository_impl.dart';
import '../data/repositories/visits_repository_impl.dart';
import '../domain/repositories/device_location_repository.dart';
import '../domain/repositories/visits_repository.dart';
import '../domain/usecases/cancel_visit.dart';
import '../domain/usecases/complete_visit.dart';
import '../domain/usecases/create_visit.dart';
import '../domain/usecases/delete_visit.dart';
import '../domain/usecases/get_current_position.dart';
import '../domain/usecases/get_visits.dart';
import '../domain/usecases/open_location_settings.dart';
import '../domain/usecases/update_visit.dart';

/// Providers del módulo locations, compuestos por `core/di/app_providers.dart`.
final locationsProviders = [
  Provider<VisitsRemoteDataSource>(
    create: (context) => VisitsRemoteDataSource(context.read<ApiClient>()),
  ),
  Provider<VisitsRepository>(
    create: (context) =>
        VisitsRepositoryImpl(context.read<VisitsRemoteDataSource>()),
  ),
  Provider<DeviceLocationRepository>(
    create: (_) =>
        const DeviceLocationRepositoryImpl(DeviceLocationDataSource()),
  ),
  Provider<GetVisits>(
    create: (context) => GetVisits(context.read<VisitsRepository>()),
  ),
  Provider<CreateVisit>(
    create: (context) => CreateVisit(context.read<VisitsRepository>()),
  ),
  Provider<UpdateVisit>(
    create: (context) => UpdateVisit(context.read<VisitsRepository>()),
  ),
  Provider<CompleteVisit>(
    create: (context) => CompleteVisit(context.read<VisitsRepository>()),
  ),
  Provider<CancelVisit>(
    create: (context) => CancelVisit(context.read<VisitsRepository>()),
  ),
  Provider<DeleteVisit>(
    create: (context) => DeleteVisit(context.read<VisitsRepository>()),
  ),
  Provider<GetCurrentPosition>(
    create: (context) =>
        GetCurrentPosition(context.read<DeviceLocationRepository>()),
  ),
  Provider<OpenLocationSettings>(
    create: (context) =>
        OpenLocationSettings(context.read<DeviceLocationRepository>()),
  ),
];
