import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/login.dart';

enum LoginFailureKind { none, unconfirmedEmail, other }

/// Estado de la pantalla de login.
class LoginController extends ChangeNotifier {
  LoginController(this._login);

  final Login _login;

  bool isLoading = false;
  String? errorMessage;
  LoginFailureKind failureKind = LoginFailureKind.none;
  int shakeCount = 0;

  Future<Session?> submit({
    required String identifier,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    failureKind = LoginFailureKind.none;
    notifyListeners();

    try {
      final session = await _login(identifier: identifier, password: password);
      return session;
    } on ApiException catch (e) {
      errorMessage = e.message;
      failureKind =
          e.status == 403 && e.message.toLowerCase().contains('confirmar')
          ? LoginFailureKind.unconfirmedEmail
          : LoginFailureKind.other;
      shakeCount++;
      return null;
    } on NetworkException catch (e) {
      errorMessage = e.message;
      failureKind = LoginFailureKind.other;
      shakeCount++;
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
