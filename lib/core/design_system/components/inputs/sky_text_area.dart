import 'package:flutter/material.dart';

import 'sky_text_field.dart';

/// Multi-line text input for longer copy (activity description).
class SkyTextArea extends StatelessWidget {
  const SkyTextArea({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.minLines = 3,
    this.maxLines = 6,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return SkyTextField(
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }
}
