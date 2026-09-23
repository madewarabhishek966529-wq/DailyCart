// DailyCart - Animation Constants
import 'package:flutter/animation.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration micro = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 280);
  static const Duration major = Duration(milliseconds: 450);
  static const Duration completion = Duration(milliseconds: 700);

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;
}
