import 'package:flutter/material.dart';
import 'package:dailycart/core/utils/format_utils.dart';

class AnimatedCountText extends StatelessWidget {
  const AnimatedCountText({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.isCurrency = false,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutCubic,
  });

  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final bool isCurrency;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        String formatted;
        if (isCurrency) {
          formatted = FormatUtils.formatCurrency(animatedValue);
        } else {
          formatted = FormatUtils.formatQuantity(animatedValue);
        }
        return Text('$prefix$formatted$suffix', style: style);
      },
    );
  }
}
