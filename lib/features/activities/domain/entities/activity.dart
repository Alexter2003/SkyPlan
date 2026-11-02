import 'time_of_day_value.dart';

enum ActivityType { outdoor, indoor }

/// `cancelled`: la canceló el usuario; `cancelledBySystem`: el sistema, por
/// mal clima en la última hora.
enum ActivityState { planned, completed, cancelled, cancelledBySystem }

/// Semáforo de la probabilidad de realización (verde 70+, amarillo 40–69,
/// rojo < 40). Lo calcula el backend.
enum ProbabilityBand { green, yellow, red }

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
    this.probability,
    this.probabilityBand,
    this.cancelReason,
    this.cancelledAt,
    this.completedAt,
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

  /// Idoneidad del clima para la franja, 0–100; `null` = aún sin pronóstico.
  final int? probability;
  final ProbabilityBand? probabilityBand;

  /// Motivo de la cancelación (del usuario o explicación del sistema).
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime? completedAt;

  /// Copia con otro estado (usada para el checkbox optimista).
  Activity copyWith({ActivityState? state}) => Activity(
    id: id,
    visitId: visitId,
    name: name,
    description: description,
    date: date,
    startTime: startTime,
    endTime: endTime,
    type: type,
    state: state ?? this.state,
    conditions: conditions,
    isViable: isViable,
    probability: probability,
    probabilityBand: probabilityBand,
    cancelReason: cancelReason,
    cancelledAt: cancelledAt,
    completedAt: completedAt,
  );

  bool get isOutdoor => type == ActivityType.outdoor;

  bool get isEditable => state == ActivityState.planned;

  bool get isCancelled =>
      state == ActivityState.cancelled ||
      state == ActivityState.cancelledBySystem;

  bool get isPendingValidation => isViable == null;

  /// Alerta: al aire libre, planeada y no viable según el clima.
  bool get needsAttention => isViable == false && isEditable;

  Set<int> get conditionIds => {for (final c in conditions) c.id};
}
