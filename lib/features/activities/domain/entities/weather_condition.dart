/// Condición climática del catálogo (`GET /weather-conditions`).
class WeatherCondition {
  const WeatherCondition({
    required this.id,
    required this.name,
    required this.description,
    required this.conflictsWith,
  });

  final int id;

  /// Identificador estable (`sunny`, `rainy`, ...).
  final String name;
  final String description;

  /// Ids que no pueden elegirse junto a esta condición.
  final Set<int> conflictsWith;
}
