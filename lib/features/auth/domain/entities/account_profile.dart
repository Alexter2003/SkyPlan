import 'auth_user.dart';

/// Perfil devuelto por `GET /users/me`: datos de cuenta y estado del
/// cambio de contraseña pendiente.
class AccountProfile {
  const AccountProfile({required this.user, required this.mustChangePassword});

  final AuthUser user;
  final bool mustChangePassword;
}
