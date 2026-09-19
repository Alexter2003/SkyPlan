import '../repositories/auth_repository.dart';

class ResendConfirmation {
  const ResendConfirmation(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) {
    return _repository.resendConfirmation(email: email);
  }
}
