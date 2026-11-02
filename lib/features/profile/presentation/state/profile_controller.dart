// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../../../../core/network/error_message.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/domain/usecases/get_account_profile.dart';
import '../../domain/usecases/update_profile.dart';

/// Estado de la pantalla de perfil: carga, edición de nombre y apellido.
class ProfileController extends ChangeNotifier {
  ProfileController({
    required GetAccountProfile getProfile,
    required UpdateProfile updateProfile,
    this.onSaved,
  }) : _getProfile = getProfile,
       _updateProfile = updateProfile;

  final GetAccountProfile _getProfile;
  final UpdateProfile _updateProfile;

  /// Se llama con el usuario actualizado tras guardar (para la sesión).
  final void Function(AuthUser user)? onSaved;

  AuthUser? user;
  bool isLoading = false;
  bool isSaving = false;
  String? loadError;
  String? saveError;
  int shakeCount = 0;

  Future<void> load() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      user = (await _getProfile()).user;
    } catch (e) {
      loadError = errorMessageOf(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Guarda solo lo que cambió. `true` si se guardó; `false` si no hubo nada
  /// que guardar o falló (revisa [saveError]).
  Future<bool> save({
    required String firstName,
    required String lastName,
  }) async {
    final current = user;
    if (current == null) return false;

    final newFirst = firstName.trim();
    final newLast = lastName.trim();
    final changedFirst = newFirst != (current.firstName ?? '')
        ? newFirst
        : null;
    final changedLast = newLast != (current.lastName ?? '') ? newLast : null;
    if (changedFirst == null && changedLast == null) return false;

    isSaving = true;
    saveError = null;
    notifyListeners();
    try {
      final updated = await _updateProfile(
        firstName: changedFirst,
        lastName: changedLast,
      );
      user = updated;
      onSaved?.call(updated);
      return true;
    } catch (e) {
      saveError = errorMessageOf(e);
      shakeCount++;
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
