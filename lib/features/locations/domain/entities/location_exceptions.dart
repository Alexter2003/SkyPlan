/// El servicio de ubicación del dispositivo está apagado.
class GpsDisabledException implements Exception {
  const GpsDisabledException();
}

/// El usuario negó el permiso de ubicación.
class GpsPermissionDeniedException implements Exception {
  const GpsPermissionDeniedException({this.permanently = false});

  /// `true` si ya no se puede volver a pedir (hay que ir a ajustes).
  final bool permanently;
}
