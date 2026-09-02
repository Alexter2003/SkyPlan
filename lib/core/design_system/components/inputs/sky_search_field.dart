import 'package:flutter/material.dart';

import '../../icons/sky_icon.dart';
import 'sky_text_field.dart';

/// Search box used by location pickers and activity filters — no label,
/// search icon leading, optional clear button once there's text.
class SkySearchField extends StatefulWidget {
  const SkySearchField({
    super.key,
    this.controller,
    this.hint = 'Buscar ubicación',
    this.onChanged,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  State<SkySearchField> createState() => _SkySearchFieldState();
}

class _SkySearchFieldState extends State<SkySearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleChange);
  }

  void _handleChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChange);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SkyTextField(
      controller: _controller,
      hint: widget.hint,
      leadingIcon: SkyIconType.search,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      trailing: _hasText
          ? IconButton(
              icon: const SkyIcon(SkyIconType.close, size: 18),
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
              },
            )
          : null,
    );
  }
}
