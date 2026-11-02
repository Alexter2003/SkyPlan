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

  Session copyWith({bool? mustChangePassword, AuthUser? user}) => Session(
    token: token,
    expiresAt: expiresAt,
    mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    user: user ?? this.user,
  );
}
