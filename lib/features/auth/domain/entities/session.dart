import 'auth_user.dart';

/// Resultado de un login exitoso.
class Session {
  const Session({
    required this.token,
    required this.expiresAt,
    required this.mustChangePassword,
    required this.user,
  });

  final String token;
  final DateTime expiresAt;
  final bool mustChangePassword;
  final AuthUser user;
}
