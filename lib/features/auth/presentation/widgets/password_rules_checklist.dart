import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/utils/validators.dart';

/// Checklist animado de las reglas de contraseña, para el registro.
class PasswordRulesChecklist extends StatelessWidget {
  const PasswordRulesChecklist({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final rules = SkyValidators.passwordRules(password);
    return Padding(
      padding: const EdgeInsets.only(top: SkySpacing.xs, left: SkySpacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final rule in rules) _RuleRow(label: rule.label, met: rule.met),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final tone = met ? colors.statusApt.background : colors.subtle;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          AnimatedContainer(
            duration: SkyMotion.fast,
            curve: SkyMotion.standard,
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? colors.statusApt.background : Colors.transparent,
              border: Border.all(color: tone, width: 1.5),
            ),
            child: AnimatedOpacity(
              duration: SkyMotion.fast,
              opacity: met ? 1 : 0,
              child: SkyIcon(
                SkyIconType.check,
                size: 12,
                color: colors.statusApt.foreground,
              ),
            ),
          ),
          const SizedBox(width: SkySpacing.xs),
          Text(label, style: typography.caption.copyWith(color: tone)),
        ],
      ),
    );
  }
}
