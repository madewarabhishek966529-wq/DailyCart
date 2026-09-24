// DailyCart - App Colors (Modern Fintech & Luxury Tech Aesthetic)
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Vibrant Emerald & Cyber Mint
  static const Color primary = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF047857);
  static const Color primaryNeon = Color(0xFF05DF72);

  // Secondary & Accents
  static const Color secondary = Color(0xFF6366F1); // Royal Indigo
  static const Color secondaryLight = Color(0xFF818CF8);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFF43F5E); // Coral Rose
  static const Color info = Color(0xFF06B6D4);

  // Backgrounds & Surfaces
  static const Color surface = Color(0xFFF8FAFC); // Crisp modern canvas
  static const Color surfaceDark = Color(0xFF0A0F1D); // Deep Obsidian
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF121929); // Sleek Midnight
  static const Color cardDarkElevated = Color(0xFF1A2234);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF1E293B);
  static const Color borderDarkSubtle = Color(0x1FFFFFFF);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Budget Status
  static const Color budgetSafe = Color(0xFF10B981);
  static const Color budgetWarning = Color(0xFFF59E0B);
  static const Color budgetOver = Color(0xFFF43F5E);

  // Priorities
  static const Color priorityHigh = Color(0xFFF43F5E);
  static const Color priorityNormal = Color(0xFF6366F1);
  static const Color priorityLow = Color(0xFF64748B);

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldNeonGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF05DF72)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberRoseGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF141C2E), Color(0xFF0E1524)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
