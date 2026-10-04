import 'api_exception.dart';

/// Mensaje en español, listo para el usuario, a partir de cualquier error.
String errorMessageOf(Object error) {
  return switch (error) {
    ApiException(:final message) => message,
    NetworkException(:final message) => message,
    _ => 'Ocurrió un error inesperado. Inténtalo de nuevo.',
  };
}
