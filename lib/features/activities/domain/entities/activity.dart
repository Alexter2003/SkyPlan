import 'time_of_day_value.dart';

enum ActivityType { outdoor, indoor }

enum ActivityState { planned, completed, cancelled }

/// Condición elegida en una actividad (`{id, name}`).
class ActivityCondition {
  const ActivityCondition({required this.id, required this.name});

  final int id;
  final String name;
}

/// Actividad dentro de una ubicación (visita).
class Activity {
  const Activity({
    required this.id,
    required this.visitId,
    required this.name,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.state,
    required this.conditions,
    this.isViable,
  });

  final int id;
  final int visitId;
  final String name;
  final String description;

  /// Heredada de la visita; no es editable.
  final DateTime date;
  final TimeOfDayValue startTime;
  final TimeOfDayValue endTime;
  final ActivityType type;

  /// Estado que decide el usuario.
  final ActivityState state;
  final List<ActivityCondition> conditions;

  /// Calculado por el sistema; `null` = aún sin pronóstico.
  final bool? isViable;

  bool get isOutdoor => type == ActivityType.outdoor;

  bool get isEditable => state == ActivityState.planned;

  bool get isPendingValidation => isViable == null;

  /// Alerta: al aire libre, planeada y no viable según el clima.
  bool get needsAttention => isViable == false && isEditable;

  Set<int> get conditionIds => {for (final c in conditions) c.id};
}
