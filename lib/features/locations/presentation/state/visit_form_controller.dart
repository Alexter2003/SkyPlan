// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/network/error_message.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/location_exceptions.dart';
import '../../domain/entities/visit.dart';
import '../../domain/usecases/create_visit.dart';
import '../../domain/usecases/get_current_position.dart';
import '../../domain/usecases/open_location_settings.dart';
import '../../domain/usecases/update_visit.dart';

enum GpsStatus { idle, loading, serviceDisabled, denied, deniedForever, failed }

/// Estado del formulario de crear/editar ubicación.
class VisitFormController extends ChangeNotifier {
  VisitFormController({
    required CreateVisit createVisit,
    required UpdateVisit updateVisit,
    required GetCurrentPosition getCurrentPosition,
    required OpenLocationSettings openSettings,
    this.editing,
  }) : _createVisit = createVisit,
       _updateVisit = updateVisit,
       _getCurrentPosition = getCurrentPosition,
       _openSettings = openSettings,
       point = editing?.point,
       date = editing?.date;

  final CreateVisit _createVisit;
  final UpdateVisit _updateVisit;
  final GetCurrentPosition _getCurrentPosition;
  final OpenLocationSettings _openSettings;

  /// Visita que se edita; `null` al crear.
  final Visit? editing;

  GeoPoint? point;
  DateTime? date;
  GpsStatus gpsStatus = GpsStatus.idle;
  bool isSubmitting = false;
  String? errorMessage;
  String? pointError;
  String? dateError;
  int shakeCount = 0;

  bool get isEditing => editing != null;

  Future<void> useCurrentLocation() async {
    gpsStatus = GpsStatus.loading;
    notifyListeners();
    try {
      point = await _getCurrentPosition();
      pointError = null;
      gpsStatus = GpsStatus.idle;
    } on GpsDisabledException {
      gpsStatus = GpsStatus.serviceDisabled;
    } on GpsPermissionDeniedException catch (e) {
      gpsStatus = e.permanently ? GpsStatus.deniedForever : GpsStatus.denied;
    } catch (_) {
      gpsStatus = GpsStatus.failed;
    }
    notifyListeners();
  }

  Future<void> openSettingsForGps() {
    return gpsStatus == GpsStatus.serviceDisabled
        ? _openSettings.service()
        : _openSettings.app();
  }

  void setPoint(GeoPoint value) {
    point = value;
    pointError = null;
    gpsStatus = GpsStatus.idle;
    notifyListeners();
  }

  void setDate(DateTime value) {
    date = value;
    dateError = null;
    notifyListeners();
  }

  /// Marca los errores de ubicación/fecha faltantes. `true` si están completos.
  bool validateSelection() {
    pointError = point == null ? 'Elige una ubicación' : null;
    dateError = date == null ? 'Elige una fecha' : null;
    final valid = pointError == null && dateError == null;
    if (!valid) shakeCount++;
    notifyListeners();
    return valid;
  }

  /// Crea o edita. Devuelve la visita guardada, o `null` si hubo error.
  Future<Visit?> submit({required String name}) async {
    if (!validateSelection()) return null;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final current = editing;
      if (current == null) {
        return await _createVisit(name: name, point: point!, date: date!);
      }
      final changedName = name != current.name ? name : null;
      final changedPoint = point != current.point ? point : null;
      final changedDate = date != current.date ? date : null;
      if (changedName == null && changedPoint == null && changedDate == null) {
        return current;
      }
      return await _updateVisit(
        current.id,
        name: changedName,
        point: changedPoint,
        date: changedDate,
      );
    } catch (e) {
      errorMessage = errorMessageOf(e);
      shakeCount++;
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
