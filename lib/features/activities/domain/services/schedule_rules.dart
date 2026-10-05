import '../entities/activity.dart';
import '../entities/time_of_day_value.dart';

/// El inicio debe ser estrictamente anterior al fin.
bool isValidRange(TimeOfDayValue start, TimeOfDayValue end) =>
    start.isBefore(end);

/// Primera actividad activa que se cruza con `[start, end)`, o `null`.
///
/// Igual que el backend: las canceladas no ocupan horario y dos actividades
/// consecutivas (una termina cuando la otra empieza) no se cruzan.
Activity? findOverlap({
  required TimeOfDayValue start,
  required TimeOfDayValue end,
  required Iterable<Activity> existing,
  int? excludeId,
}) {
  for (final other in existing) {
    if (other.id == excludeId) continue;
    if (other.state == ActivityState.cancelled) continue;
    if (start.isBefore(other.endTime) && other.startTime.isBefore(end)) {
      return other;
    }
  }
  return null;
}
