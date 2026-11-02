import '../entities/activity.dart';

/// Acciones sobre el ciclo de vida de una actividad.
enum ActivityOperation { complete, uncomplete, cancel, reactivate, reschedule }

/// Acciones válidas según el estado (misma regla que documenta el backend):
/// pendiente → completar/cancelar/reagendar; completada → desmarcar;
/// canceladas (usuario o sistema) → reactivar/reagendar.
Set<ActivityOperation> availableOperations(ActivityState state) {
  return switch (state) {
    ActivityState.planned => {
      ActivityOperation.complete,
      ActivityOperation.cancel,
      ActivityOperation.reschedule,
    },
    ActivityState.completed => {ActivityOperation.uncomplete},
    ActivityState.cancelled || ActivityState.cancelledBySystem => {
      ActivityOperation.reactivate,
      ActivityOperation.reschedule,
    },
  };
}

/// El checkbox del checklist solo aplica a pendientes (marcar) y completadas
/// (desmarcar).
bool canToggleComplete(ActivityState state) =>
    state == ActivityState.planned || state == ActivityState.completed;
