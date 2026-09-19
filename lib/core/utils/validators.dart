/// Validadores compartidos por los formularios de la app.
abstract final class SkyValidators {
  static final RegExp _emailPattern = RegExp(
    r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$',
  );

  static String? required(String? value, {String field = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field es obligatorio';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, field: 'El correo');
    if (requiredError != null) return requiredError;
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String field = 'Este campo',
  }) {
    final requiredError = required(value, field: field);
    if (requiredError != null) return requiredError;
    if (value!.trim().length < min) {
      return '$field debe tener al menos $min caracteres';
    }
    return null;
  }

  /// Regla de contraseña: 8–72 caracteres, mayúscula, minúscula y dígito.
  static String? password(String? value) {
    final requiredError = required(value, field: 'La contraseña');
    if (requiredError != null) return requiredError;
    final v = value!;
    if (v.length < 8 || v.length > 72) {
      return 'La contraseña debe tener entre 8 y 72 caracteres';
    }
    if (!RegExp(r'[a-z]').hasMatch(v) ||
        !RegExp(r'[A-Z]').hasMatch(v) ||
        !RegExp(r'\d').hasMatch(v)) {
      return 'La contraseña debe combinar mayúsculas, minúsculas y números';
    }
    return null;
  }

  /// Checklist en vivo de las reglas de contraseña, para el registro.
  static List<({String label, bool met})> passwordRules(String value) {
    return [
      (
        label: 'Entre 8 y 72 caracteres',
        met: value.length >= 8 && value.length <= 72,
      ),
      (label: 'Al menos una minúscula', met: RegExp(r'[a-z]').hasMatch(value)),
      (label: 'Al menos una mayúscula', met: RegExp(r'[A-Z]').hasMatch(value)),
      (label: 'Al menos un número', met: RegExp(r'\d').hasMatch(value)),
    ];
  }

  static final RegExp _usernamePattern = RegExp(r'^[A-Za-z0-9._-]+$');

  /// Nombre de usuario: 3–50 caracteres, letras/números/`.`/`_`/`-`.
  static String? username(String? value) {
    final requiredError = required(value, field: 'El nombre de usuario');
    if (requiredError != null) return requiredError;
    final v = value!.trim();
    if (v.length < 3 || v.length > 50) {
      return 'El nombre de usuario debe tener entre 3 y 50 caracteres';
    }
    if (!_usernamePattern.hasMatch(v)) {
      return 'Solo letras, números, puntos, guiones y guiones bajos';
    }
    return null;
  }

  /// Identificador de login: correo o usuario, 3–255 caracteres.
  static String? loginIdentifier(String? value) {
    final requiredError = required(value, field: 'El correo o usuario');
    if (requiredError != null) return requiredError;
    final length = value!.trim().length;
    if (length < 3 || length > 255) {
      return 'Ingresa un correo o usuario válido';
    }
    return null;
  }

  /// Código de confirmación: 5 caracteres alfanuméricos.
  static String? confirmationCode(String? value) {
    final requiredError = required(value, field: 'El código');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[A-Za-z0-9]{5}$').hasMatch(value!.trim())) {
      return 'El código debe tener 5 caracteres alfanuméricos';
    }
    return null;
  }

  static String? passwordsMatch(String? confirmation, String original) {
    final requiredError = required(confirmation, field: 'La confirmación');
    if (requiredError != null) return requiredError;
    if (confirmation != original) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static bool rangesOverlap(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) {
    return startA.isBefore(endB) && startB.isBefore(endA);
  }
}
