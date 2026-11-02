import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_message.dart';
import '../../domain/usecases/change_password.dart';

enum ChangePasswordOutcome { success, temporaryExpired, failed }

/// Estado de la pantalla de cambio de contraseña obligatorio.
class ChangePasswordController extends ChangeNotifier {
  ChangePasswordController(this._changePassword);

  final ChangePassword _changePassword;

  /// Fragmento del 403 cuando la contraseña temporal ya venció.
  static const temporaryExpiredMarker = 'temporal expiró';

  bool isLoading = false;
  String? errorMessage;
  List<String> errorDetails = const [];
  int shakeCount = 0;

  Future<ChangePasswordOutcome> submit({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    isLoading = true;
    errorMessage = null;
    errorDetails = const [];
    notifyListeners();

    try {
      await _changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      return ChangePasswordOutcome.success;
    } on ApiException catch (e) {
      errorMessage = e.message;
      shakeCount++;
      if (e.status == 403 &&
          e.message.toLowerCase().contains(temporaryExpiredMarker)) {
        return ChangePasswordOutcome.temporaryExpired;
      }
      errorDetails = e.status == 400
          ? e.details.where((d) => d != e.message).toList()
          : const [];
      return ChangePasswordOutcome.failed;
    } catch (e) {
      errorMessage = errorMessageOf(e);
      shakeCount++;
      return ChangePasswordOutcome.failed;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
