// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/network/error_message.dart';
import '../../domain/entities/activity.dart';
import '../../domain/usecases/delete_activity.dart';
import '../../domain/usecases/get_activities_by_visit.dart';

/// Estado del detalle de actividades de una ubicación.
class VisitActivitiesController extends ChangeNotifier {
  VisitActivitiesController({
    required this.visitId,
    required GetActivitiesByVisit getActivities,
    required DeleteActivity deleteActivity,
  }) : _getActivities = getActivities,
       _deleteActivity = deleteActivity;

  final int visitId;
  final GetActivitiesByVisit _getActivities;
  final DeleteActivity _deleteActivity;

  List<Activity> activities = const [];
  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  final Set<int> busyIds = {};

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
}
