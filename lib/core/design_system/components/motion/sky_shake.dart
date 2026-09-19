import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../tokens/sky_motion.dart';

/// Agita horizontalmente [child] cada vez que cambia [shakeKey] (ej. un
/// contador que se incrementa en cada error).
class SkyShake extends StatefulWidget {
  const SkyShake({
    super.key,
    required this.shakeKey,
    required this.child,
    this.amplitude = 8,
  });

  final Object shakeKey;
  final Widget child;
  final double amplitude;

  @override
  State<SkyShake> createState() => _SkyShakeState();
}

class _SkyShakeState extends State<SkyShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SkyMotion.fast * 3,
  );

  @override
  void didUpdateWidget(covariant SkyShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shakeKey != widget.shakeKey) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final decay = 1 - t;
        final wave = math.sin(t * 4 * math.pi) * decay;
        return Transform.translate(
          offset: Offset(wave * widget.amplitude, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
