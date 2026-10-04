import '../../domain/entities/geo_point.dart';
import '../../domain/repositories/device_location_repository.dart';
import '../datasources/device_location_datasource.dart';

class DeviceLocationRepositoryImpl implements DeviceLocationRepository {
  const DeviceLocationRepositoryImpl(this._source);

  final DeviceLocationDataSource _source;

  @override
  Future<GeoPoint> getCurrentPosition() => _source.getCurrentPosition();

  @override
  Future<void> openLocationSettings() => _source.openLocationSettings();

  @override
  Future<void> openAppSettings() => _source.openAppSettings();
}
