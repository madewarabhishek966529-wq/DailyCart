// DailyCart - Text Styles (Modern Hierarchy & Tabular Numerals)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme get textTheme => GoogleFonts.plusJakartaSansTextTheme();

  static TextStyle display(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle heading1(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle heading2(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle heading3(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyMedium(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle caption(BuildContext context) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle label(BuildContext context) => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle eyebrow(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle price(BuildContext context) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: Theme.of(context).colorScheme.primary,
      );

  static TextStyle statNumber(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: -0.5,
        color: Theme.of(context).colorScheme.onSurface,
      );
}
