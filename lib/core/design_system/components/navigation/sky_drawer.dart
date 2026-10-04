import 'package:flutter/material.dart';

import '../../icons/sky_icon.dart';
import '../../tokens/sky_colors.dart';
import '../../tokens/sky_shapes.dart';
import '../../tokens/sky_spacing.dart';
import '../../tokens/sky_typography.dart';
import '../feedback/sky_badge.dart';
import '../surfaces/sky_divider.dart';

/// Menú lateral de la app: [header] arriba, [items] al centro y [footer]
/// anclado abajo. Borde derecho grueso, como el resto de superficies Bauhaus.
class SkyDrawer extends StatelessWidget {
  const SkyDrawer({
    super.key,
    required this.header,
    required this.items,
    this.footer = const [],
  });

  final Widget header;
  final List<Widget> items;
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final shapes = context.skyShapes;

    return Drawer(
      backgroundColor: colors.surface,
      shape: Border(
        right: BorderSide(color: colors.ink, width: shapes.borderThick),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(SkySpacing.md),
              child: header,
            ),
            const SkyDivider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(SkySpacing.sm),
                children: items,
              ),
            ),
            if (footer.isNotEmpty) ...[
              const SkyDivider(),
              Padding(
                padding: const EdgeInsets.all(SkySpacing.sm),
                child: Column(children: footer),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Opción del [SkyDrawer]. Seleccionada = relleno azul; deshabilitada =
/// atenuada con insignia [disabledLabel]; destructiva = rojo.
class SkyDrawerItem extends StatelessWidget {
  const SkyDrawerItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.selected = false,
    this.enabled = true,
    this.destructive = false,
    this.loading = false,
    this.disabledLabel = 'Pronto',
  });

  final SkyIconType icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final bool enabled;
  final bool destructive;
  final bool loading;
  final String disabledLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final shapes = context.skyShapes;

    final Color foreground;
    if (!enabled) {
      foreground = colors.subtle;
    } else if (selected) {
      foreground = colors.onAccent;
    } else if (destructive) {
      foreground = colors.primaryRed;
    } else {
      foreground = colors.ink;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: SkySpacing.xxs),
      child: Material(
        color: selected && enabled ? colors.primaryBlue : Colors.transparent,
        borderRadius: shapes.radiusMd,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled && !loading ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SkySpacing.sm,
                vertical: SkySpacing.xs,
              ),
              child: Row(
                children: [
                  SkyIcon(icon, size: 22, color: foreground),
                  const SizedBox(width: SkySpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: typography.bodyStrong.copyWith(color: foreground),
                    ),
                  ),
                  if (loading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: foreground,
                      ),
                    )
                  else if (!enabled)
                    SkyBadge(
                      label: disabledLabel,
                      background: colors.border,
                      foreground: colors.ink,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
