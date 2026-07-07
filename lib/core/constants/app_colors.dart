// ============================================================
// app_colors.dart
// All color constants used throughout the app in one place.
// Having colors here means we only need to change one file
// to update the app's color scheme.
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  // ---- Private constructor so nobody can create AppColors() ----
  AppColors._();

  static bool isLightMode = false;

  // ----- Background Colors -----
  static Color get background => isLightMode ? const Color(0xFFF9FAFB) : const Color(0xFF0D0D1A);
  static Color get surface => isLightMode ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A2E);
  static Color get surfaceLight => isLightMode ? const Color(0xFFF3F4F6) : const Color(0xFF16213E);
  static Color get border => isLightMode ? const Color(0xFFE5E7EB) : const Color(0xFF2A2A4A);

  // ----- Accent / Brand Colors -----
  static Color get accent => const Color(0xFF7C3AED);
  static Color get accentLight => const Color(0xFF9D5CF6);
  static Color get accentDark => const Color(0xFF5B21B6);

  // ----- Semantic Colors -----
  static Color get credit => const Color(0xFF22C55E);
  static Color get debit => const Color(0xFFEF4444);
  static Color get transfer => const Color(0xFFF59E0B);

  // ----- Text Colors -----
  static Color get textPrimary => isLightMode ? const Color(0xFF111827) : const Color(0xFFFFFFFF);
  static Color get textSecondary => isLightMode ? const Color(0xFF4B5563) : const Color(0xFFA0A0B0);
  static Color get textHint => isLightMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B6B80);

  // ----- Gradient Definitions -----
  static LinearGradient get purpleGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
  );

  static LinearGradient get cardGradient => isLightMode
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1E3A), Color(0xFF16162A)],
        );

  // ----- Preset Colors for Category Picker -----
  /// A palette of colors users can pick for their categories
  static const List<Color> categoryColors = [
    Color(0xFF7C3AED), // Purple
    Color(0xFF22C55E), // Green
    Color(0xFFEF4444), // Red
    Color(0xFFF59E0B), // Orange
    Color(0xFF3B82F6), // Blue
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFF84CC16), // Lime
    Color(0xFFF97316), // Deep Orange
    Color(0xFF8B5CF6), // Violet
    Color(0xFF14B8A6), // Teal
    Color(0xFFD97706), // Amber
  ];
}
