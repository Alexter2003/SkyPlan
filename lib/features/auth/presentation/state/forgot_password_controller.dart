import 'package:flutter/foundation.dart';

import '../../../../core/network/error_message.dart';
import '../../domain/usecases/forgot_password.dart';

/// Estado de la pantalla "olvidé mi contraseña".
class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController(this._forgotPassword);

  final ForgotPassword _forgotPassword;

  bool isLoading = false;
  bool sent = false;
  String? errorMessage;
  int shakeCount = 0;

  Future<void> submit({required String email}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _forgotPassword(email: email);
      sent = true;
    } catch (e) {
      errorMessage = errorMessageOf(e);
      shakeCount++;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
