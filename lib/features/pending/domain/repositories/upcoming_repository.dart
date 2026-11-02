import '../entities/upcoming_filters.dart';
import '../entities/upcoming_page.dart';

/// Contrato del listado de actividades próximas.
abstract class UpcomingRepository {
  Future<UpcomingPage> getUpcoming(UpcomingFilters filters);
}
