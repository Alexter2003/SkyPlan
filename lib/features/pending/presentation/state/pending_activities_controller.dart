// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_message.dart';
import '../../../activities/domain/entities/activity.dart';
import '../../../activities/domain/usecases/cancel_activity.dart';
import '../../../activities/domain/usecases/complete_activity.dart';
import '../../../activities/domain/usecases/reactivate_activity.dart';
import '../../../activities/domain/usecases/uncomplete_activity.dart';
import '../../domain/entities/upcoming_activity.dart';
import '../../domain/entities/upcoming_filters.dart';
import '../../domain/usecases/get_upcoming_activities.dart';

/// Error de una acción sobre una actividad, listo para mostrar.
class PendingActionError {
  const PendingActionError(this.message, {this.offerReschedule = false});

  final String message;

  /// Reactivar falló por cruce de horario (409) o porque ya terminó (400):
  /// la salida natural es reagendar.
  final bool offerReschedule;
}

/// Estado de la pantalla de pendientes: listado filtrado y acciones.
///
/// El backend es la fuente de verdad (filtros, probabilidad, validación): el
/// controller solo reemplaza cada actividad con la respuesta de la acción y
/// vuelve a pedir la lista al refrescar o cambiar filtros.
class PendingActivitiesController extends ChangeNotifier {
  PendingActivitiesController({
    required GetUpcomingActivities getUpcoming,
    required CompleteActivity completeActivity,
    required UncompleteActivity uncompleteActivity,
    required CancelActivity cancelActivity,
    required ReactivateActivity reactivateActivity,
  }) : _getUpcoming = getUpcoming,
       _complete = completeActivity,
       _uncomplete = uncompleteActivity,
       _cancel = cancelActivity,
       _reactivate = reactivateActivity;

  final GetUpcomingActivities _getUpcoming;
  final CompleteActivity _complete;
  final UncompleteActivity _uncomplete;
  final CancelActivity _cancel;
  final ReactivateActivity _reactivate;

  UpcomingFilters filters = const UpcomingFilters();
  List<UpcomingActivity> items = const [];
  int total = 0;
  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  final Set<int> busyIds = {};

  int _requestId = 0;

  bool get hasFilters => filters.isActive;

  /// Hay más actividades en el servidor que las mostradas.
  bool get hasMore => total > items.length;

  /// Pide la lista con los filtros actuales. [silent] no muestra el esqueleto
  /// (refresco al volver, pull-to-refresh).
  Future<void> load({bool silent = false}) async {
    final request = ++_requestId;
    if (!silent || !hasLoaded) {
      isLoading = true;
      notifyListeners();
    }
    errorMessage = null;
    try {
      final page = await _getUpcoming(filters);
      if (request != _requestId) return;
      items = page.items;
      total = page.total;
      hasLoaded = true;
    } catch (e) {
      if (request != _requestId) return;
      errorMessage = errorMessageOf(e);
    } finally {
      if (request == _requestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Aplica nuevos filtros (todos combinados) y recarga.
  Future<void> applyFilters(UpcomingFilters value) {
    filters = value;
    return load();
  }

  Future<void> clearFilters() => applyFilters(filters.cleared());

  /// Checkbox: completa o desmarca. Optimista, con reversión si falla.
  /// Devuelve el error o `null`.
  Future<PendingActionError?> toggleComplete(UpcomingActivity item) {
    final completing = item.activity.state != ActivityState.completed;
    final previous = item.activity;
    _replace(
      item.id,
      (current) => current.withActivity(
        previous.copyWith(
          state: completing ? ActivityState.completed : ActivityState.planned,
        ),
      ),
    );
    return _run(item.id, () async {
      final result = completing
          ? await _complete(item.id)
          : await _uncomplete(item.id);
      _replace(
        item.id,
        (current) => current.withActivity(
          result.activity,
          visitStatus: result.visitStatus,
        ),
      );
    }, onError: () => _replace(item.id, (c) => c.withActivity(previous)));
  }

  /// Cancelación manual; el motivo es opcional.
  Future<PendingActionError?> cancel(UpcomingActivity item, {String? reason}) {
    return _run(item.id, () async {
      final result = await _cancel(item.id, reason: reason);
      _replace(
        item.id,
        (current) => current.withActivity(
          result.activity,
          visitStatus: result.visitStatus,
        ),
      );
    });
  }

  Future<PendingActionError?> reactivate(UpcomingActivity item) {
    return _run(item.id, () async {
      final activity = await _reactivate(item.id);
      _replace(item.id, (current) => current.withActivity(activity));
    });
  }

  /// Reemplaza una actividad con la respuesta de otra acción (reagendar).
  /// Como pudo cambiar de día o de ubicación, se vuelve a pedir la lista.
  Future<void> applyRescheduled(Activity activity) async {
    _replace(activity.id, (current) => current.withActivity(activity));
    await load(silent: true);
  }

  Future<PendingActionError?> _run(
    int id,
    Future<void> Function() action, {
    VoidCallback? onError,
  }) async {
    busyIds.add(id);
    notifyListeners();
    try {
      await action();
      return null;
    } catch (e) {
      onError?.call();
      return PendingActionError(
        errorMessageOf(e),
        offerReschedule:
            e is ApiException &&
            (e.status == 409 ||
                (e.status == 400 &&
                    e.message.toLowerCase().contains('terminó'))),
      );
    } finally {
      busyIds.remove(id);
      notifyListeners();
    }
  }

  void _replace(int id, UpcomingActivity Function(UpcomingActivity) change) {
    items = [for (final item in items) item.id == id ? change(item) : item];
    notifyListeners();
  }
}
