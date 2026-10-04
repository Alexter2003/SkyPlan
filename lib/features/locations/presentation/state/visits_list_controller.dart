// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/network/error_message.dart';
import '../../domain/entities/visit.dart';
import '../../domain/usecases/cancel_visit.dart';
import '../../domain/usecases/complete_visit.dart';
import '../../domain/usecases/delete_visit.dart';
import '../../domain/usecases/get_visits.dart';

/// Estado del listado de ubicaciones y sus acciones por item.
class VisitsListController extends ChangeNotifier {
  VisitsListController({
    required GetVisits getVisits,
    required CompleteVisit completeVisit,
    required CancelVisit cancelVisit,
    required DeleteVisit deleteVisit,
  }) : _getVisits = getVisits,
       _completeVisit = completeVisit,
       _cancelVisit = cancelVisit,
       _deleteVisit = deleteVisit;

  final GetVisits _getVisits;
  final CompleteVisit _completeVisit;
  final CancelVisit _cancelVisit;
  final DeleteVisit _deleteVisit;

  List<Visit> visits = const [];
  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  VisitStatus selectedTab = VisitStatus.planned;
  final Set<int> busyIds = {};

  List<Visit> visitsFor(VisitStatus status) =>
      visits.where((v) => v.status == status).toList();

  int countFor(VisitStatus status) =>
      visits.where((v) => v.status == status).length;

  void selectTab(VisitStatus status) {
    if (selectedTab == status) return;
    selectedTab = status;
    notifyListeners();
  }

  /// Carga la lista. Con [silent] no muestra skeleton si ya hay datos
  /// (refresco al volver a primer plano).
  Future<void> load({bool silent = false}) async {
    if (isLoading) return;
    isLoading = !(silent && hasLoaded);
    errorMessage = null;
    notifyListeners();

    try {
      visits = await _getVisits();
      hasLoaded = true;
    } catch (e) {
      errorMessage = errorMessageOf(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Devuelve `null` si salió bien, o el mensaje de error.
  Future<String?> complete(Visit visit) => _run(visit, () async {
    _replace(await _completeVisit(visit.id));
  });

  Future<String?> cancel(Visit visit) => _run(visit, () async {
    _replace(await _cancelVisit(visit.id));
  });

  Future<String?> delete(Visit visit) => _run(visit, () async {
    await _deleteVisit(visit.id);
    visits = visits.where((v) => v.id != visit.id).toList();
  });

  Future<String?> _run(Visit visit, Future<void> Function() action) async {
    busyIds.add(visit.id);
    notifyListeners();
    try {
      await action();
      return null;
    } catch (e) {
      return errorMessageOf(e);
    } finally {
      busyIds.remove(visit.id);
      notifyListeners();
    }
  }

  void _replace(Visit updated) {
    visits = [for (final v in visits) v.id == updated.id ? updated : v];
  }
}
