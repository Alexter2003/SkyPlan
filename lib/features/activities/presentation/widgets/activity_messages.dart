import '../../domain/entities/activity.dart';

/// Mensaje de éxito tras guardar.
String activitySavedMessage(Activity saved, {required bool edited}) {
  return edited ? 'Actividad actualizada' : 'Actividad creada';
}
