import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/profile_remote_datasource.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/update_profile.dart';

/// Providers del módulo profile, compuestos por `core/di/app_providers.dart`.
final profileProviders = [
  Provider<ProfileRepository>(
    create: (context) => ProfileRepositoryImpl(
      ProfileRemoteDataSource(context.read<ApiClient>()),
    ),
  ),
  Provider<UpdateProfile>(
    create: (context) => UpdateProfile(context.read<ProfileRepository>()),
  ),
];
