import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/change_password.dart';
import '../domain/usecases/confirm_email.dart';
import '../domain/usecases/forgot_password.dart';
import '../domain/usecases/get_account_profile.dart';
import '../domain/usecases/login.dart';
import '../domain/usecases/logout.dart';
import '../domain/usecases/register_user.dart';
import '../domain/usecases/resend_confirmation.dart';

/// Providers del módulo auth, compuestos por `core/di/app_providers.dart`.
final authProviders = [
  Provider<AuthRemoteDataSource>(
    create: (context) => AuthRemoteDataSource(context.read<ApiClient>()),
  ),
  Provider<AuthRepository>(
    create: (context) =>
        AuthRepositoryImpl(context.read<AuthRemoteDataSource>()),
  ),
  Provider<RegisterUser>(
    create: (context) => RegisterUser(context.read<AuthRepository>()),
  ),
  Provider<ConfirmEmail>(
    create: (context) => ConfirmEmail(context.read<AuthRepository>()),
  ),
  Provider<ResendConfirmation>(
    create: (context) => ResendConfirmation(context.read<AuthRepository>()),
  ),
  Provider<Login>(create: (context) => Login(context.read<AuthRepository>())),
  Provider<Logout>(create: (context) => Logout(context.read<AuthRepository>())),
  Provider<ForgotPassword>(
    create: (context) => ForgotPassword(context.read<AuthRepository>()),
  ),
  Provider<ChangePassword>(
    create: (context) => ChangePassword(context.read<AuthRepository>()),
  ),
  Provider<GetAccountProfile>(
    create: (context) => GetAccountProfile(context.read<AuthRepository>()),
  ),
];
