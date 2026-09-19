import 'dart:async';

import 'package:flutter/material.dart';

import '../../tokens/sky_motion.dart';

/// Entrada animada con fade + deslizamiento hacia arriba. Usa [delay] para
/// escalonar varios elementos (ej. `index * 60ms`).
class SkyFadeSlideIn extends StatefulWidget {
  const SkyFadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = SkyMotion.base,
    this.offset = 12,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;

  @override
  State<SkyFadeSlideIn> createState() => _SkyFadeSlideInState();
}

class _SkyFadeSlideInState extends State<SkyFadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: SkyMotion.standard,
  );
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    if (reduceMotion) {
      _controller.value = 1;
      return;
    }
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fade,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _fade.value) * widget.offset),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
