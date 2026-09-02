import 'package:flutter/material.dart';

import '../../../utils/validators.dart';
import '../buttons/sky_icon_button.dart';
import '../../icons/sky_icon.dart';
import 'sky_text_field.dart';

/// Password field with a visibility toggle, built for the login screen and
/// the double-confirmation change-password screen (requirement 2.c: pass
/// [confirms] the original password's current value to validate a match).
class SkyPasswordField extends StatefulWidget {
  const SkyPasswordField({
    super.key,
    this.controller,
    this.label = 'Contraseña',
    this.validator,
    this.confirms,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String label;
  final String? Function(String?)? validator;

  /// When set, this field validates as a confirmation of [confirms]'s
  /// current value using [SkyValidators.passwordsMatch], instead of
  /// [validator].
  final String Function()? confirms;

  final TextInputAction? textInputAction;

  @override
  State<SkyPasswordField> createState() => _SkyPasswordFieldState();
}

class _SkyPasswordFieldState extends State<SkyPasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return SkyTextField(
      controller: widget.controller,
      label: widget.label,
      obscureText: !_visible,
      textInputAction: widget.textInputAction,
      autofillHints: const [AutofillHints.password],
      validator: widget.confirms != null
          ? (value) => SkyValidators.passwordsMatch(value, widget.confirms!())
          : (widget.validator ?? SkyValidators.password),
      trailing: SkyIconButton(
        icon: _visible ? SkyIconType.eyeOff : SkyIconType.eye,
        tooltip: _visible ? 'Ocultar contraseña' : 'Mostrar contraseña',
        onPressed: () => setState(() => _visible = !_visible),
      ),
    );
  }
}
