import 'package:flutter/material.dart';

// Full implementation coming in Phase 5
class ProgressBarWidget extends StatelessWidget {
  const ProgressBarWidget({super.key, required this.value});
  final double value;
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(value: value);
  }
}
