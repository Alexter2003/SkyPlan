import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../features/auth/di/auth_providers.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/presentation/state/session_controller.dart';
import '../../features/activities/di/activities_providers.dart';
import '../../features/locations/di/locations_providers.dart';
import '../../features/notifications/di/notifications_providers.dart';
import '../network/api_client.dart';
import '../storage/session_storage.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SessionStorage>(create: (_) => SecureSessionStorage()),
        Provider<ApiClient>(
          create: (context) {
            final storage = context.read<SessionStorage>();
            return ApiClient(
              tokenProvider: () async => (await storage.read())?.token,
            );
          },
          dispose: (_, c) => c.close(),
        ),
        ...authProviders,
        ...locationsProviders,
        ...activitiesProviders,
        ChangeNotifierProvider<SessionController>(
          create: (context) => SessionController(
            storage: context.read<SessionStorage>(),
            logout: context.read<Logout>(),
            unauthorized: context.read<ApiClient>().unauthorized,
          ),
        ),
        ...notificationsProviders,
      ],
      child: child,
    );
  }
}
