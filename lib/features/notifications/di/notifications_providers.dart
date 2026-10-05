import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/state/session_controller.dart';
import '../data/datasources/flutter_local_notifier.dart';
import '../data/datasources/notifications_remote_datasource.dart';
import '../data/datasources/socket_notifications_source.dart';
import '../data/repositories/notifications_repository_impl.dart';
import '../domain/repositories/local_notifier.dart';
import '../domain/repositories/notifications_repository.dart';
import '../domain/repositories/realtime_notifications_source.dart';
import '../presentation/state/notifications_controller.dart';

/// Providers del módulo notifications. Deben ir después del `SessionController`.
final notificationsProviders = [
  Provider<NotificationsRepository>(
    create: (context) => NotificationsRepositoryImpl(
      NotificationsRemoteDataSource(context.read<ApiClient>()),
    ),
  ),
  Provider<RealtimeNotificationsSource>(
    create: (_) => SocketNotificationsSource(),
  ),
  Provider<LocalNotifier>(create: (_) => FlutterLocalNotifier()),
  ChangeNotifierProvider<NotificationsController>(
    lazy: false,
    create: (context) => NotificationsController(
      session: context.read<SessionController>(),
      repository: context.read<NotificationsRepository>(),
      realtime: context.read<RealtimeNotificationsSource>(),
      notifier: context.read<LocalNotifier>(),
    )..start(),
  ),
];
