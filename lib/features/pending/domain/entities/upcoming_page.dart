import 'upcoming_activity.dart';

/// Página de actividades próximas.
class UpcomingPage {
  const UpcomingPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<UpcomingActivity> items;
  final int page;
  final int limit;

  /// Total que cumple los filtros (puede superar [items]).
  final int total;

  bool get hasMore => total > items.length;
}
