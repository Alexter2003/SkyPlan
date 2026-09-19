import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../features/auth/di/auth_providers.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/presentation/state/session_controller.dart';
import '../network/api_client.dart';
import '../storage/session_storage.dart';

/// Composición de la DI: infraestructura core + providers por feature.
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => ApiClient(),
          dispose: (_, c) => c.close(),
        ),
        Provider<SessionStorage>(create: (_) => SecureSessionStorage()),
        ...authProviders,
        // ...locationsProviders, ...activitiesProviders, etc.
        ChangeNotifierProvider<SessionController>(
          create: (context) => SessionController(
            storage: context.read<SessionStorage>(),
            logout: context.read<Logout>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
