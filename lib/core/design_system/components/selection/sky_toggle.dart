import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_motion.dart';

/// Boolean on/off switch — used for the theme toggle and any binary
/// preference (e.g. "recibir notificaciones del clima").
class SkyToggle extends StatelessWidget {
  const SkyToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: SkyMotion.fast,
        curve: SkyMotion.standard,
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? colors.primaryBlue : colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.ink, width: 2),
        ),
        child: AnimatedAlign(
          duration: SkyMotion.fast,
          curve: SkyMotion.standard,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? colors.onAccent : colors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
