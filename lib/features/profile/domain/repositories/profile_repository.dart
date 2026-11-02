import '../../../auth/domain/entities/auth_user.dart';

/// Contrato de edición del perfil. La lectura vive en el módulo auth
/// (`GetAccountProfile`), que ya consulta `GET /users/me`.
abstract class ProfileRepository {
  /// Solo se envían los campos no nulos; devuelve el perfil actualizado.
  Future<AuthUser> update({String? firstName, String? lastName});
}
