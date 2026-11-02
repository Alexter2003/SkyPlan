// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/network/error_message.dart';
import '../../../locations/domain/entities/visit.dart';
import '../../domain/entities/activity.dart';
import '../../domain/usecases/complete_activity.dart';
import '../../domain/usecases/delete_activity.dart';
import '../../domain/usecases/get_activities_by_visit.dart';
import '../../domain/usecases/uncomplete_activity.dart';

/// Estado del detalle de actividades de una ubicación.
class VisitActivitiesController extends ChangeNotifier {
  VisitActivitiesController({
    required this.visitId,
    required GetActivitiesByVisit getActivities,
    required DeleteActivity deleteActivity,
    required CompleteActivity completeActivity,
    required UncompleteActivity uncompleteActivity,
    this.visitStatus = VisitStatus.planned,
  }) : _getActivities = getActivities,
       _deleteActivity = deleteActivity,
       _complete = completeActivity,
       _uncomplete = uncompleteActivity;

  final int visitId;
  final GetActivitiesByVisit _getActivities;
  final DeleteActivity _deleteActivity;
  final CompleteActivity _complete;
  final UncompleteActivity _uncomplete;

  /// Estado de la ubicación; se actualiza con el `visitStatus` de cada
  /// acción del checklist, sin volver a pedirla.
  VisitStatus visitStatus;

  List<Activity> activities = const [];
  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  final Set<int> busyIds = {};

  /// Actividades que cuentan para el checklist: las canceladas no se hacen.
  int get checklistTotal => activities.where((a) => !a.isCancelled).length;

  int get checklistDone =>
      activities.where((a) => a.state == ActivityState.completed).length;

  Future<void> load({bool silent = false}) async {
    if (isLoading) return;
    isLoading = !(silent && hasLoaded);
    errorMessage = null;
    notifyListeners();

    try {
      activities = await _getActivities(visitId);
      hasLoaded = true;
    } catch (e) {
      errorMessage = errorMessageOf(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> delete(Activity activity) async {
    busyIds.add(activity.id);
    notifyListeners();
    try {
      await _deleteActivity(activity.id);
      activities = activities.where((a) => a.id != activity.id).toList();
      return null;
    } catch (e) {
      return errorMessageOf(e);
    } finally {
      busyIds.remove(activity.id);
      notifyListeners();
    }
  }

  /// Checklist: marca o desmarca. Optimista, con reversión si falla.
  /// Devuelve el mensaje de error o `null`.
  Future<String?> toggleComplete(Activity activity) async {
    final completing = activity.state != ActivityState.completed;
    _replace(
      activity.id,
      activity.copyWith(
        state: completing ? ActivityState.completed : ActivityState.planned,
      ),
    );
    busyIds.add(activity.id);
    notifyListeners();
    try {
      final result = completing
          ? await _complete(activity.id)
          : await _uncomplete(activity.id);
      _replace(activity.id, result.activity);
      visitStatus = result.visitStatus ?? visitStatus;
      return null;
    } catch (e) {
      _replace(activity.id, activity);
      return errorMessageOf(e);
    } finally {
      busyIds.remove(activity.id);
      notifyListeners();
    }
  }

  void _replace(int id, Activity value) {
    activities = [for (final a in activities) a.id == id ? value : a];
    notifyListeners();
  }
}
