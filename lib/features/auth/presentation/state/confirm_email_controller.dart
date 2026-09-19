// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/confirm_email.dart';
import '../../domain/usecases/resend_confirmation.dart';

const _resendSuccessMessage =
    'Se envió un nuevo código de confirmación a tu correo';

/// Estado de la pantalla de confirmación de correo, incluido el cooldown
/// de reenvío.
class ConfirmEmailController extends ChangeNotifier {
  ConfirmEmailController({
    required this.email,
    required ConfirmEmail confirmEmail,
    required ResendConfirmation resendConfirmation,
    int initialCooldownSeconds = 60,
  }) : _confirmEmail = confirmEmail,
       _resendConfirmation = resendConfirmation {
    _startCooldown(initialCooldownSeconds);
  }

  final String email;
  final ConfirmEmail _confirmEmail;
  final ResendConfirmation _resendConfirmation;

  bool isVerifying = false;
  bool isResending = false;
  String? errorMessage;
  String? resendMessage;
  AuthUser? confirmedUser;
  bool alreadyConfirmed = false;
  int shakeCount = 0;

  int cooldownSeconds = 0;
  Timer? _timer;

  bool get canResend => cooldownSeconds <= 0 && !isResending;

  void _startCooldown(int seconds) {
    _timer?.cancel();
    cooldownSeconds = seconds;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      cooldownSeconds -= 1;
      if (cooldownSeconds <= 0) {
        cooldownSeconds = 0;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  Future<void> verify(String code) async {
    if (isVerifying) return;
    isVerifying = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _confirmEmail(email: email, code: code);
      confirmedUser = user;
    } on ApiException catch (e) {
      if (e.status == 409) {
        alreadyConfirmed = true;
      } else {
        errorMessage = e.message;
        shakeCount++;
        if (e.status == 429) {
          _timer?.cancel();
          cooldownSeconds = 0;
        }
      }
    } on NetworkException catch (e) {
      errorMessage = e.message;
      shakeCount++;
    } finally {
      isVerifying = false;
      notifyListeners();
    }
  }

  Future<void> resend() async {
    if (!canResend) return;
    isResending = true;
    errorMessage = null;
    resendMessage = null;
    notifyListeners();

    try {
      await _resendConfirmation(email: email);
      resendMessage = _resendSuccessMessage;
      _startCooldown(60);
    } on ApiException catch (e) {
      if (e.status == 409) {
        alreadyConfirmed = true;
      } else {
        errorMessage = e.message;
      }
    } on NetworkException catch (e) {
      errorMessage = e.message;
    } finally {
      isResending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
