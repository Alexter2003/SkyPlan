/// Error de la API (status no-2xx). [message] ya viene en español, listo
/// para mostrar al usuario.
class ApiException implements Exception {
  const ApiException({
    required this.status,
    required this.message,
    this.details = const [],
  });

  final int status;
  final String message;
  final List<String> details;

  @override
  String toString() => 'ApiException($status): $message';
}

/// La petición no llegó al servidor (sin conexión, timeout).
class NetworkException implements Exception {
  const NetworkException([
    this.message =
        'No pudimos conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
  ]);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}
