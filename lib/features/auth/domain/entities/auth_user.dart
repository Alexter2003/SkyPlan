/// Datos de cuenta devueltos por la API.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    required this.emailConfirmed,
    required this.createdAt,
  });

  final int id;
  final String email;
  final String username;
  final bool emailConfirmed;
  final DateTime createdAt;
}
