import 'package:geolocator/geolocator.dart';

import '../../domain/entities/geo_point.dart';
import '../../domain/entities/location_exceptions.dart';

/// GPS del teléfono vía `geolocator`.
class DeviceLocationDataSource {
  const DeviceLocationDataSource();

  Future<GeoPoint> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const GpsDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const GpsPermissionDeniedException(permanently: true);
    }
    if (permission == LocationPermission.denied) {
      throw const GpsPermissionDeniedException();
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return GeoPoint(latitude: position.latitude, longitude: position.longitude);
  }

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
