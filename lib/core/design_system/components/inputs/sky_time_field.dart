import 'package:flutter/material.dart';

import '../../icons/sky_icon.dart';
import 'sky_text_field.dart';

/// Read-only field that opens [showTimePicker] — used by activity creation
/// (horario) alongside [SkyDateField].
class SkyTimeField extends StatelessWidget {
  const SkyTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Hora',
    this.errorText,
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  final String label;
  final String? errorText;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _pick(context),
        child: AbsorbPointer(
          child: SkyTextField(
            label: label,
            leadingIcon: SkyIconType.clock,
            errorText: errorText,
            controller: TextEditingController(
              text: value == null ? '' : value!.format(context),
            ),
          ),
        ),
      ),
    );
  }
}
