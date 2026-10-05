// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_message.dart';
import '../../../locations/domain/entities/visit.dart';
import '../../../locations/domain/usecases/get_visits.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/time_of_day_value.dart';
import '../../domain/entities/weather_condition.dart';
import '../../domain/services/schedule_rules.dart';
import '../../domain/usecases/create_activity.dart';
import '../../domain/usecases/get_activities_by_visit.dart';
import '../../domain/usecases/get_weather_conditions.dart';
import '../../domain/usecases/update_activity.dart';

/// Estado del formulario de crear/editar una actividad.
class ActivityFormController extends ChangeNotifier {
  ActivityFormController({
    required CreateActivity createActivity,
    required UpdateActivity updateActivity,
    required GetWeatherConditions getConditions,
    required GetActivitiesByVisit getActivities,
    required GetVisits getVisits,
    this.editing,
    this.visit,
  }) : _createActivity = createActivity,
       _updateActivity = updateActivity,
       _getConditions = getConditions,
       _getActivities = getActivities,
       _getVisits = getVisits,
       type = editing?.type ?? ActivityType.outdoor,
       startTime = editing?.startTime,
       endTime = editing?.endTime,
       selectedConditions = {...?editing?.conditionIds};

  final CreateActivity _createActivity;
  final UpdateActivity _updateActivity;
  final GetWeatherConditions _getConditions;
  final GetActivitiesByVisit _getActivities;
  final GetVisits _getVisits;

  /// Actividad que se edita; `null` al crear.
  final Activity? editing;

  /// Ubicación elegida (en edición viene fija).
  Visit? visit;

  ActivityType type;
  TimeOfDayValue? startTime;
  TimeOfDayValue? endTime;
  Set<int> selectedConditions;

  /// Ubicaciones planeadas donde se puede registrar una actividad.
  List<Visit> visits = const [];
  List<WeatherCondition> catalog = const [];
  List<Activity> siblings = const [];
  bool isLoadingCatalog = false;
  bool isSubmitting = false;
  String? catalogError;

  String? errorMessage;
  String? visitError;
  String? timeError;
  String? conditionsError;
  int shakeCount = 0;

  /// La ubicación ya no existe (404): la pantalla debe cerrarse.
  bool notFound = false;

  bool get isEditing => editing != null;

  Future<void> init() async {
    isLoadingCatalog = true;
    catalogError = null;
    notifyListeners();
    try {
      final results = await Future.wait([_getConditions(), _getVisits()]);
      catalog = results[0] as List<WeatherCondition>;
      visits = (results[1] as List<Visit>)
          .where((v) => v.status == VisitStatus.planned)
          .toList();
      final preselected = visit;
      if (preselected != null) {
        visit =
            visits.where((v) => v.id == preselected.id).firstOrNull ??
            preselected;
      }
      await _loadSiblings();
    } catch (e) {
      catalogError = errorMessageOf(e);
    } finally {
      isLoadingCatalog = false;
      notifyListeners();
    }
  }

  Future<void> _loadSiblings() async {
    final current = visit;
    siblings = current == null ? const [] : await _getActivities(current.id);
  }

  Future<void> selectVisit(Visit value) async {
    visit = value;
    visitError = null;
    timeError = null;
    notifyListeners();
    try {
      await _loadSiblings();
    } catch (_) {
      siblings = const [];
    }
    _validateTimes();
    notifyListeners();
  }

  void setType(ActivityType value) {
    type = value;
    errorMessage = null;
    notifyListeners();
  }

  void setStart(TimeOfDayValue value) {
    startTime = value;
    _validateTimes();
    notifyListeners();
  }

  void setEnd(TimeOfDayValue value) {
    endTime = value;
    _validateTimes();
    notifyListeners();
  }

  void setConditions(Set<int> value) {
    selectedConditions = value;
    conditionsError = null;
    errorMessage = null;
    notifyListeners();
  }

  /// Validación optimista de horario (rango y cruce con otras actividades).
  /// Devuelve `true` si no hay error.
  bool _validateTimes() {
    final start = startTime;
    final end = endTime;
    timeError = null;
    if (start == null || end == null) return true;
    if (!isValidRange(start, end)) {
      timeError = 'La hora de inicio debe ser anterior a la hora de fin';
      return false;
    }
    final overlap = findOverlap(
      start: start,
      end: end,
      existing: siblings,
      excludeId: editing?.id,
    );
    if (overlap != null) {
      timeError =
          "El horario se cruza con la actividad '${overlap.name}' "
          '(${overlap.startTime.format()}–${overlap.endTime.format()})';
      return false;
    }
    return true;
  }

  /// Marca los campos faltantes y los errores de cliente. `true` si es válido.
  bool validateSelection() {
    visitError = visit == null ? 'Elige una ubicación' : null;
    if (startTime == null || endTime == null) {
      timeError = 'Elige la hora de inicio y de fin';
    } else {
      _validateTimes();
    }
    conditionsError = selectedConditions.isEmpty
        ? 'Elige al menos una condición climática'
        : null;
    final valid =
        visitError == null && timeError == null && conditionsError == null;
    if (!valid) shakeCount++;
    notifyListeners();
    return valid;
  }

  /// Crea o edita. Devuelve la actividad guardada, o `null` si hubo error.
  Future<Activity?> submit({
    required String name,
    required String description,
  }) async {
    if (!validateSelection()) return null;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final current = editing;
      if (current == null) {
        return await _createActivity(
          visitId: visit!.id,
          name: name,
          description: description,
          startTime: startTime!,
          endTime: endTime!,
          type: type,
          weatherConditionIds: selectedConditions.toList()..sort(),
        );
      }

      final changedName = name != current.name ? name : null;
      final changedDescription = description != current.description
          ? description
          : null;
      final changedStart = startTime != current.startTime ? startTime : null;
      final changedEnd = endTime != current.endTime ? endTime : null;
      final changedType = type != current.type ? type : null;
      final changedConditions =
          !setEquals(selectedConditions, current.conditionIds)
          ? (selectedConditions.toList()..sort())
          : null;

      if (changedName == null &&
          changedDescription == null &&
          changedStart == null &&
          changedEnd == null &&
          changedType == null &&
          changedConditions == null) {
        return current;
      }
      return await _updateActivity(
        current.id,
        name: changedName,
        description: changedDescription,
        startTime: changedStart,
        endTime: changedEnd,
        type: changedType,
        weatherConditionIds: changedConditions,
      );
    } catch (e) {
      errorMessage = _messageFor(e);
      if (e case ApiException(status: 404)) notFound = true;
      shakeCount++;
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  /// 422: el pronóstico bloquea la actividad; se añade una sugerencia.
  String _messageFor(Object error) {
    final message = errorMessageOf(error);
    if (error is ApiException && error.status == 422) {
      return '$message. Prueba cambiar las condiciones, el tipo o el horario.';
    }
    return message;
  }
}
