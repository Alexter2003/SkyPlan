import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/presentation/state/session_controller.dart';

/// Pantalla principal tras el login.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    await context.read<SessionController>().endSession();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  String _formatExpiry(DateTime expiresAt) {
    final local = expiresAt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m/${local.year} $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final session = context.watch<SessionController>().session;
    final user = session?.user;

    return SkyScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const SkyLogo(showTagline: false, markSize: 28),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SkySpacing.xs),
            child: _loggingOut
                ? const SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    ),
                  )
                : SkyIconButton(
                    icon: SkyIconType.logout,
                    tooltip: 'Cerrar sesión',
                    onPressed: _logout,
                  ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkyFadeSlideIn(
                child: Row(
                  children: [
                    SkyIcon(
                      SkyIconType.shieldCheck,
                      size: 32,
                      color: colors.statusApt.background,
                    ),
                    const SizedBox(width: SkySpacing.sm),
                    Expanded(
                      child: Text(
                        'Hola, ${user?.username ?? ''}',
                        style: typography.display,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SkySpacing.xxs),
              SkyFadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: const SkyBadge(label: 'Sesión activa'),
              ),
              const SizedBox(height: SkySpacing.lg),
              if (user != null && session != null)
                SkyFadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: SkyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SkyIcon(
                              SkyIconType.mail,
                              size: 18,
                              color: colors.subtle,
                            ),
                            const SizedBox(width: SkySpacing.xs),
                            Expanded(
                              child: Text(user.email, style: typography.body),
                            ),
                          ],
                        ),
                        const SizedBox(height: SkySpacing.xs),
                        SkyDivider(),
                        const SizedBox(height: SkySpacing.xs),
                        Row(
                          children: [
                            Text(
                              'Correo confirmado',
                              style: typography.caption,
                            ),
                            const Spacer(),
                            SkyBadge(
                              label: user.emailConfirmed ? 'Sí' : 'No',
                              background: user.emailConfirmed
                                  ? colors.statusApt.background
                                  : colors.statusCaution.background,
                              foreground: user.emailConfirmed
                                  ? colors.statusApt.foreground
                                  : colors.statusCaution.foreground,
                            ),
                          ],
                        ),
                        const SizedBox(height: SkySpacing.xs),
                        Text(
                          'Tu sesión vence el ${_formatExpiry(session.expiresAt)}',
                          style: typography.caption.copyWith(
                            color: colors.subtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              if (kDebugMode)
                SkyFadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: SkySpacing.sm),
                    child: SkyButton(
                      label: 'Ver UI kit',
                      variant: SkyButtonVariant.ghost,
                      expand: true,
                      onPressed: () => Navigator.of(context).pushNamed('/kit'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
