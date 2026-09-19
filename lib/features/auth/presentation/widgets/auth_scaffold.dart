import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// Estructura común de las pantallas de auth: logo, título y contenido.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.leading,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final typography = context.skyTypography;
    final colors = context.skyColors;

    return SkyScaffold(
      appBar: leading == null
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: leading,
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            // Centra si cabe; hace scroll normal si no (ej. con teclado).
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: SkySpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SkyFadeSlideIn(
                          child: const Center(
                            child: SkyLogo(showTagline: false, markSize: 56),
                          ),
                        ),
                        const SizedBox(height: SkySpacing.xl),
                        SkyFadeSlideIn(
                          delay: const Duration(milliseconds: 60),
                          child: Text(title, style: typography.display),
                        ),
                        const SizedBox(height: SkySpacing.xxs),
                        SkyFadeSlideIn(
                          delay: const Duration(milliseconds: 100),
                          child: Text(
                            subtitle,
                            style: typography.body.copyWith(
                              color: colors.subtle,
                            ),
                          ),
                        ),
                        const SizedBox(height: SkySpacing.xl),
                        for (var i = 0; i < children.length; i++)
                          SkyFadeSlideIn(
                            delay: Duration(milliseconds: 140 + i * 60),
                            child: children[i],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
