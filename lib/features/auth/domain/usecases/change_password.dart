import '../repositories/auth_repository.dart';

class ChangePassword {
  const ChangePassword(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }
}
