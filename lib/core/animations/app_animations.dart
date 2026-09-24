// DailyCart - Animation Constants & Micro-Interactions Engine
import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration micro = Duration(milliseconds: 140);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 280);
  static const Duration smooth = Duration(milliseconds: 360);
  static const Duration major = Duration(milliseconds: 480);
  static const Duration completion = Duration(milliseconds: 700);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve spring = Curves.elasticOut;
  static const Curve springBack = Curves.easeOutBack;
  static const Curve decelerate = Curves.decelerate;
}

/// Staggered Entrance Animation (Slides and Fades in smoothly)
class FadeSlideTransition extends StatefulWidget {
  const FadeSlideTransition({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.offset = const Offset(0.0, 0.08),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  @override
  State<FadeSlideTransition> createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<FadeSlideTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slideAnimation =
        Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(curved);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// Subtle Breathing Glow effect for hero elements and status badges
class PulseGlowAnimation extends StatefulWidget {
  const PulseGlowAnimation({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF10B981),
    this.duration = const Duration(milliseconds: 1800),
    this.maxBlur = 16.0,
    this.minBlur = 4.0,
  });

  final Widget child;
  final Color glowColor;
  final Duration duration;
  final double maxBlur;
  final double minBlur;

  @override
  State<PulseGlowAnimation> createState() => _PulseGlowAnimationState();
}

class _PulseGlowAnimationState extends State<PulseGlowAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final blur =
            widget.minBlur + (widget.maxBlur - widget.minBlur) * _animation.value;
        final opacity = 0.2 + (0.25 * _animation.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: opacity),
                blurRadius: blur,
                spreadRadius: 1,
              ),
            ],
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
