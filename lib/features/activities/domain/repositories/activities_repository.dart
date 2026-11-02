import '../entities/activity.dart';
import '../entities/activity_action_result.dart';
import '../entities/time_of_day_value.dart';

/// Contrato de actividades.
abstract class ActivitiesRepository {
  Future<List<Activity>> getByVisit(int visitId);

  Future<Activity> create({
    required int visitId,
    required String name,
    required String description,
    required TimeOfDayValue startTime,
    required TimeOfDayValue endTime,
    required ActivityType type,
    required List<int> weatherConditionIds,
  });

  /// Solo se envían los campos no nulos.
  Future<Activity> update(
    int id, {
    String? name,
    String? description,
    TimeOfDayValue? startTime,
    TimeOfDayValue? endTime,
    ActivityType? type,
    List<int>? weatherConditionIds,
  });

  Future<void> delete(int id);

  /// Checklist: marca la actividad como completada.
  Future<ActivityActionResult> complete(int id);

  /// Deshace un completado hecho por error.
  Future<ActivityActionResult> uncomplete(int id);

  /// Cancelación manual; [reason] opcional (1–500 caracteres).
  Future<ActivityActionResult> cancel(int id, {String? reason});

  /// Revierte una cancelación (del usuario o del sistema).
  Future<Activity> reactivate(int id);

  /// Mueve la actividad a otra fecha y horario; el backend revalida.
  Future<Activity> reschedule(
    int id, {
    required DateTime date,
    required TimeOfDayValue startTime,
    required TimeOfDayValue endTime,
  });
}
