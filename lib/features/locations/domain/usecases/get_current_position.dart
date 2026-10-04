import '../entities/geo_point.dart';
import '../repositories/device_location_repository.dart';

class GetCurrentPosition {
  const GetCurrentPosition(this._repository);

  final DeviceLocationRepository _repository;

  Future<GeoPoint> call() => _repository.getCurrentPosition();
}
