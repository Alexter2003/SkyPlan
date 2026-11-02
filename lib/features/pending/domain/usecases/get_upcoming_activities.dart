import '../entities/upcoming_filters.dart';
import '../entities/upcoming_page.dart';
import '../repositories/upcoming_repository.dart';

class GetUpcomingActivities {
  const GetUpcomingActivities(this._repository);

  final UpcomingRepository _repository;

  Future<UpcomingPage> call([
    UpcomingFilters filters = const UpcomingFilters(),
  ]) => _repository.getUpcoming(filters);
}
