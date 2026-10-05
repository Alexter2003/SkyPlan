// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/network/error_message.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/visit_activities.dart';
import '../../domain/usecases/delete_activity.dart';
import '../../domain/usecases/get_activities_grouped_by_visit.dart';

/// Estado del listado global de actividades agrupadas por ubicación.
class ActivitiesOverviewController extends ChangeNotifier {
  ActivitiesOverviewController({
    required GetActivitiesGroupedByVisit getGrouped,
    required DeleteActivity deleteActivity,
  }) : _getGrouped = getGrouped,
       _deleteActivity = deleteActivity;

  final GetActivitiesGroupedByVisit _getGrouped;
  final DeleteActivity _deleteActivity;

  List<VisitActivities> groups = const [];
  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  final Set<int> busyIds = {};

  bool get isEmpty => groups.every((g) => g.activities.isEmpty);

  /// Con [silent] no muestra skeleton si ya hay datos.
  Future<void> load({bool silent = false}) async {
    if (isLoading) return;
    isLoading = !(silent && hasLoaded);
    errorMessage = null;
    notifyListeners();

    try {
      groups = await _getGrouped();
      hasLoaded = true;
    } catch (e) {
      errorMessage = errorMessageOf(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Devuelve `null` si salió bien, o el mensaje de error.
  Future<String?> delete(Activity activity) async {
    busyIds.add(activity.id);
    notifyListeners();
    try {
      await _deleteActivity(activity.id);
      groups = [
        for (final g in groups)
          VisitActivities(
            visit: g.visit,
            activities: g.activities.where((a) => a.id != activity.id).toList(),
          ),
      ];
      return null;
    } catch (e) {
      return errorMessageOf(e);
    } finally {
      busyIds.remove(activity.id);
      notifyListeners();
    }
  }
}
