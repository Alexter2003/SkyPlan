// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/network/error_message.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/time_of_day_value.dart';
import '../../domain/services/schedule_rules.dart';
import '../../domain/usecases/reschedule_activity.dart';

/// Estado del reagendado: nueva fecha y horario, validados en el cliente y
/// luego por el backend (cruces, otra ubicación ese día, pronóstico).
class RescheduleController extends ChangeNotifier {
  RescheduleController({
    required RescheduleActivity rescheduleActivity,
    required this.activity,
    DateTime? today,
  }) : _reschedule = rescheduleActivity,
       today = _dateOnly(today ?? DateTime.now()),
       date = activity.date,
       startTime = activity.startTime,
       endTime = activity.endTime {
    if (date.isBefore(this.today)) date = this.today;
  }

  final RescheduleActivity _reschedule;
  final Activity activity;
  final DateTime today;

  DateTime date;
  TimeOfDayValue startTime;
  TimeOfDayValue endTime;

  bool isSubmitting = false;

  /// Error de un campo detectado en el cliente.
  String? dateError;
  String? timeError;

  /// Mensaje del backend (409, 422, ...), tal cual, sin reinterpretar.
  String? serverError;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void setDate(DateTime value) {
    date = _dateOnly(value);
    dateError = null;
    serverError = null;
    notifyListeners();
  }

  void setStart(TimeOfDayValue value) {
    startTime = value;
    timeError = null;
    serverError = null;
    notifyListeners();
  }

  void setEnd(TimeOfDayValue value) {
    endTime = value;
    timeError = null;
    serverError = null;
    notifyListeners();
  }

  /// `true` si no hay errores de cliente.
  bool validate() {
    dateError = date.isBefore(today)
        ? 'La fecha no puede estar en el pasado'
        : null;
    timeError = isValidRange(startTime, endTime)
        ? null
        : 'La hora de inicio debe ser anterior a la hora de fin';
    notifyListeners();
    return dateError == null && timeError == null;
  }

  /// Envía el cambio. Devuelve la actividad reagendada, o `null` si hubo un
  /// error de cliente o del backend (ver [serverError]).
  Future<Activity?> submit() async {
    if (!validate()) return null;

    isSubmitting = true;
    serverError = null;
    notifyListeners();
    try {
      return await _reschedule(
        activity.id,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      serverError = errorMessageOf(e);
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
