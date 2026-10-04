import '../entities/geo_point.dart';

/// Acceso al GPS del teléfono.
abstract class DeviceLocationRepository {
  /// Lanza `GpsDisabledException` o
  /// `GpsPermissionDeniedException` según el caso.
  Future<GeoPoint> getCurrentPosition();

  Future<void> openLocationSettings();

  Future<void> openAppSettings();
}
