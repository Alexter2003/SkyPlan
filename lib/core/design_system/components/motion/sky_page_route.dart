import 'package:flutter/material.dart';

import '../../tokens/sky_motion.dart';

/// Transición de página estándar: fade + deslizamiento suave.
class SkyPageRoute<T> extends PageRouteBuilder<T> {
  SkyPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: SkyMotion.slow,
        reverseTransitionDuration: SkyMotion.base,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: SkyMotion.emphasized,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}
