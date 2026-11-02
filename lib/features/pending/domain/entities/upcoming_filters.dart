import '../../../activities/domain/entities/activity.dart';

enum UpcomingSort { date, probability }

const _unset = Object();

/// Filtros y orden del listado de pendientes. Se combinan en una sola
/// petición; `null` = sin filtrar por ese criterio.
class UpcomingFilters {
  const UpcomingFilters({
    this.days,
    this.visitId,
    this.probabilityMin,
    this.probabilityMax,
    this.state,
    this.sortBy = UpcomingSort.date,
    this.ascending = true,
    this.limit = 100,
  });

  /// Proximidad: desde hoy hasta hoy + [days] (1–365).
  final int? days;
  final int? visitId;
  final int? probabilityMin;
  final int? probabilityMax;
  final ActivityState? state;
  final UpcomingSort sortBy;
  final bool ascending;
  final int limit;

  /// Hay algún criterio de filtrado (el orden no cuenta).
  bool get isActive =>
      days != null ||
      visitId != null ||
      probabilityMin != null ||
      probabilityMax != null ||
      state != null;

  /// Con filtro de probabilidad, el backend excluye las de `null`.
  bool get filtersByProbability =>
      probabilityMin != null || probabilityMax != null;

  /// Para vaciar un criterio, pásalo explícitamente como `null`.
  UpcomingFilters copyWith({
    Object? days = _unset,
    Object? visitId = _unset,
    Object? probabilityMin = _unset,
    Object? probabilityMax = _unset,
    Object? state = _unset,
    UpcomingSort? sortBy,
    bool? ascending,
  }) {
    return UpcomingFilters(
      days: identical(days, _unset) ? this.days : days as int?,
      visitId: identical(visitId, _unset) ? this.visitId : visitId as int?,
      probabilityMin: identical(probabilityMin, _unset)
          ? this.probabilityMin
          : probabilityMin as int?,
      probabilityMax: identical(probabilityMax, _unset)
          ? this.probabilityMax
          : probabilityMax as int?,
      state: identical(state, _unset) ? this.state : state as ActivityState?,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      limit: limit,
    );
  }

  /// Quita los criterios de filtrado y conserva el orden.
  UpcomingFilters cleared() =>
      UpcomingFilters(sortBy: sortBy, ascending: ascending, limit: limit);
}
