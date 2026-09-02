import 'package:flutter/material.dart';

import '../../icons/sky_icon.dart';
import 'sky_text_field.dart';

/// Read-only field that opens [showDatePicker] and formats the result as
/// `dd/mm/yyyy`. Used by activity creation (fecha) and location/activity
/// filters (proximidad de fecha).
class SkyDateField extends StatelessWidget {
  const SkyDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Fecha',
    this.firstDate,
    this.lastDate,
    this.errorText,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String label;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? errorText;

  String _format(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(now.year - 1),
      lastDate: lastDate ?? DateTime(now.year + 2),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: AbsorbPointer(
        child: SkyTextField(
          label: label,
          leadingIcon: SkyIconType.calendar,
          errorText: errorText,
          controller: TextEditingController(
            text: value == null ? '' : _format(value!),
          ),
        ),
      ),
    );
  }
}
