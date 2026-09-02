import 'package:flutter/material.dart';

import '../../../utils/validators.dart';
import '../../icons/sky_icon.dart';
import 'sky_text_field.dart';

/// Email field with built-in format validation
/// ([SkyValidators.email]) — used by login, recovery, and the user profile.
class SkyEmailField extends StatelessWidget {
  const SkyEmailField({
    super.key,
    this.controller,
    this.label = 'Correo electrónico',
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String label;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return SkyTextField(
      controller: controller,
      label: label,
      leadingIcon: SkyIconType.mail,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      validator: SkyValidators.email,
    );
  }
}
