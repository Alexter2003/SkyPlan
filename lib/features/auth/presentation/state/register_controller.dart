import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/register_user.dart';

/// Estado de la pantalla de registro.
class RegisterController extends ChangeNotifier {
  RegisterController(this._registerUser);

  final RegisterUser _registerUser;

  bool isLoading = false;
  String? errorMessage;
  List<String> errorDetails = const [];
  String? registeredEmail;
  int shakeCount = 0;

  Future<void> submit({
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) async {
    isLoading = true;
    errorMessage = null;
    errorDetails = const [];
    notifyListeners();

    try {
      await _registerUser(
        email: email,
        username: username,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      registeredEmail = email;
    } on ApiException catch (e) {
      errorMessage = e.message;
      errorDetails = e.status == 400
          ? e.details.where((d) => d != e.message).toList()
          : const [];
      shakeCount++;
    } on NetworkException catch (e) {
      errorMessage = e.message;
      shakeCount++;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    errorDetails = const [];
    notifyListeners();
  }
}
