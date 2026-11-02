import '../../../auth/domain/entities/auth_user.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  /// Nunca envía `username`, `email` ni `password`: el backend los rechaza.
  Future<AuthUser> call({String? firstName, String? lastName}) {
    return _repository.update(firstName: firstName, lastName: lastName);
  }
}
