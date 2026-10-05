import '../../domain/entities/viability_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  Future<List<ViabilityNotification>> fetchUnread() => _remote.fetchUnread();

  @override
  Future<void> markRead(int id) => _remote.markRead(id);
}
