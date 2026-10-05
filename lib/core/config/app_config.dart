/// Configuración de build vía `--dart-define`.
abstract final class AppConfig {
  /// URL base de la API SkyPlan (incluye `/api`).
  static const String apiBaseUrl = String.fromEnvironment(
    'SKYPLAN_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  /// Origen del servidor para el socket (la API sin el prefijo `/api`).
  static String get socketBaseUrl => apiBaseUrl.endsWith('/api')
      ? apiBaseUrl.substring(0, apiBaseUrl.length - 4)
      : apiBaseUrl;
}
