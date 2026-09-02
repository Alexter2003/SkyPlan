/// Pure, framework-free validators shared by every form in the app
/// (`auth`, `user`, `locations`, `activities`, `pending_activities`).
///
/// Each function returns `null` when the value is valid, or a
/// Spanish-language error message otherwise — the shape
/// [TextFormField.validator] and the kit's input widgets expect.
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

  /// Password rule: at least 8 characters, one letter and one number —
  /// enough to defend in the oral evaluation without being punitive.
  static String? password(String? value) {
    final requiredError = required(value, field: 'La contraseña');
    if (requiredError != null) return requiredError;
    final v = value!;
    if (v.length < 8) return 'La contraseña debe tener al menos 8 caracteres';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'La contraseña debe combinar letras y números';
    }
    return null;
  }

  /// Validates a confirmation field against the original password value —
  /// used by the double-confirmation change-password screen (req. 2.c).
  static String? passwordsMatch(String? confirmation, String original) {
    final requiredError = required(confirmation, field: 'La confirmación');
    if (requiredError != null) return requiredError;
    if (confirmation != original) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// True when two [DateTime] ranges (each `[start, end)`) overlap — the
  /// rule behind requirement 4.a.i ("no se crucen entre sí").
  static bool rangesOverlap(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) {
    return startA.isBefore(endB) && startB.isBefore(endA);
  }
}
