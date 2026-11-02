import '../../domain/entities/upcoming_filters.dart';
import '../../domain/entities/upcoming_page.dart';
import '../../domain/repositories/upcoming_repository.dart';
import '../datasources/upcoming_remote_datasource.dart';

class UpcomingRepositoryImpl implements UpcomingRepository {
  const UpcomingRepositoryImpl(this._remote);

  final UpcomingRemoteDataSource _remote;

  @override
  Future<UpcomingPage> getUpcoming(UpcomingFilters filters) =>
      _remote.getUpcoming(filters);
}
