import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../icons/sky_icon.dart';
import '../../tokens/sky_colors.dart';
import '../../tokens/sky_typography.dart';

/// SkyPlan's base text input. Every specialized field in this kit
/// ([SkyPasswordField], [SkyEmailField], [SkySearchField], [SkyTextArea]...)
/// is built on top of this one instead of a raw [TextField], so label
/// style, error style, and border tokens never drift between them.
///
/// Uses the `InputDecorationTheme` registered by `SkyTheme` — no per-field
/// color overrides here, only structural options (icons, obscure text,
/// max lines).
class SkyTextField extends StatelessWidget {
  const SkyTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.validator,
    this.onChanged,
    this.leadingIcon,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.autofillHints,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final SkyIconType? leadingIcon;
  final Widget? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      enabled: enabled,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      style: typography.body.copyWith(color: colors.ink),
      cursorColor: colors.primaryBlue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: leadingIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.all(12),
                child: SkyIcon(leadingIcon!, size: 20, color: colors.subtle),
              ),
        suffixIcon: trailing,
      ),
    );
  }
}
