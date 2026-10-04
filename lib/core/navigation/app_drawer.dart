import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/state/session_controller.dart';
import '../design_system/design_system.dart';
import '../routing/app_routes.dart';

/// Menú lateral de la app. [currentRoute] marca la sección activa.
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _loggingOut = false;

  void _go(String route) {
    final navigator = Navigator.of(context)..pop();
    if (route == widget.currentRoute) return;
    navigator.pushNamedAndRemoveUntil(route, (_) => false);
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    final navigator = Navigator.of(context);
    await context.read<SessionController>().endSession();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final user = context.watch<SessionController>().session?.user;
    final theme = SkyThemeScope.of(context);

    return SkyDrawer(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkyLogo(showTagline: false, markSize: 32),
          if (user != null) ...[
            const SizedBox(height: SkySpacing.md),
            Text(user.username, style: typography.title),
            Text(
              user.email,
              style: typography.caption.copyWith(color: colors.subtle),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      items: [
        SkyDrawerItem(
          icon: SkyIconType.home,
          label: 'Inicio',
          selected: widget.currentRoute == AppRoutes.home,
          onTap: () => _go(AppRoutes.home),
        ),
        SkyDrawerItem(
          icon: SkyIconType.location,
          label: 'Mis ubicaciones',
          selected: widget.currentRoute == AppRoutes.locations,
          onTap: () => _go(AppRoutes.locations),
        ),
        const SkyDrawerItem(
          icon: SkyIconType.calendar,
          label: 'Actividades',
          enabled: false,
        ),
        const SkyDrawerItem(
          icon: SkyIconType.clock,
          label: 'Pendientes',
          enabled: false,
        ),
        const SkyDrawerItem(
          icon: SkyIconType.user,
          label: 'Mi perfil',
          enabled: false,
        ),
      ],
      footer: [
        SkyDrawerItem(
          icon: theme.isDark ? SkyIconType.sun : SkyIconType.cloud,
          label: theme.isDark ? 'Tema claro' : 'Tema oscuro',
          onTap: theme.toggle,
        ),
        SkyDrawerItem(
          icon: SkyIconType.logout,
          label: 'Cerrar sesión',
          destructive: true,
          loading: _loggingOut,
          onTap: _logout,
        ),
      ],
    );
  }
}
