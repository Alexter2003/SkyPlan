import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_motion.dart';
import '../../tokens/sky_shapes.dart';
import '../../tokens/sky_spacing.dart';
import '../../tokens/sky_typography.dart';

/// Fila de casillas para un código alfanumérico corto.
class SkyCodeField extends StatefulWidget {
  const SkyCodeField({
    super.key,
    this.length = 5,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.autofocus = false,
  });

  final int length;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool autofocus;

  @override
  State<SkyCodeField> createState() => SkyCodeFieldState();
}

class SkyCodeFieldState extends State<SkyCodeField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _previous = '';

  /// Limpia el código actual — se usa tras un intento rechazado.
  void clear() {
    _controller.clear();
    setState(() => _previous = '');
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleChange);
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() => setState(() {});

  void _handleChange() {
    final value = _controller.text;
    setState(() => _previous = value);
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChange);
    _focusNode.removeListener(_handleFocusChange);
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final shapes = context.skyShapes;
    final typography = context.skyTypography;
    final activeIndex = _previous.length.clamp(0, widget.length - 1);

    return GestureDetector(
      onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  UpperCaseTextFormatter(),
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                maxLength: widget.length,
                decoration: const InputDecoration(counterText: ''),
              ),
            ),
          ),
          IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i != 0) const SizedBox(width: SkySpacing.xs),
                  _CodeBox(
                    character: i < _previous.length ? _previous[i] : '',
                    active:
                        widget.enabled &&
                        _focusNode.hasFocus &&
                        i == activeIndex,
                    colors: colors,
                    shapes: shapes,
                    typography: typography,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.character,
    required this.active,
    required this.colors,
    required this.shapes,
    required this.typography,
  });

  final String character;
  final bool active;
  final SkyColors colors;
  final SkyShapes shapes;
  final SkyTypography typography;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: SkyMotion.fast,
      curve: SkyMotion.standard,
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shapes.radiusSm,
        border: Border.all(
          color: active ? colors.primaryBlue : colors.ink,
          width: active ? shapes.borderThick : shapes.borderThin,
        ),
      ),
      child: AnimatedSwitcher(
        duration: SkyMotion.fast,
        child: Text(
          character,
          key: ValueKey(character),
          style: typography.headline.copyWith(color: colors.ink),
        ),
      ),
    );
  }
}

/// Fuerza mayúsculas, igual que la normalización del código en el backend.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
