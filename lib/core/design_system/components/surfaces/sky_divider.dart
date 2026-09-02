import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';

/// Thick divider for section breaks (matches the card's border weight) vs.
/// a plain hairline for in-list separators.
class SkyDivider extends StatelessWidget {
  const SkyDivider({super.key, this.thick = false});

  final bool thick;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    return Divider(
      color: thick ? colors.ink : colors.border,
      thickness: thick ? 3 : 1,
      height: thick ? 32 : 1,
    );
  }
}
