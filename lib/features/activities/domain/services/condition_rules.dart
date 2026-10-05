import '../entities/weather_condition.dart';

/// Ids que no se pueden elegir dado lo ya seleccionado (unión de los
/// `conflictsWith` de cada condición elegida, en ambos sentidos).
Set<int> blockedConditionIds(
  Set<int> selected,
  Iterable<WeatherCondition> catalog,
) {
  final blocked = <int>{};
  for (final condition in catalog) {
    if (selected.contains(condition.id)) {
      blocked.addAll(condition.conflictsWith);
    } else if (condition.conflictsWith.any(selected.contains)) {
      blocked.add(condition.id);
    }
  }
  return blocked..removeAll(selected);
}
