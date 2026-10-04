import '../repositories/device_location_repository.dart';

/// Abre los ajustes del sistema para activar el GPS o dar permisos.
class OpenLocationSettings {
  const OpenLocationSettings(this._repository);

  final DeviceLocationRepository _repository;

  Future<void> service() => _repository.openLocationSettings();

  Future<void> app() => _repository.openAppSettings();
}
