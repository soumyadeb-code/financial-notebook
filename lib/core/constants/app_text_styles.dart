// ============================================================
// app_text_styles.dart
// All text styles in one place.
// Uses Poppins font bundled locally in assets/fonts/Poppins/
// (No network fetch — avoids SocketException on restricted networks)
// ============================================================

import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ----- Display (very large) -----
  /// Used for the big balance number on the Net Worth card
  static TextStyle displayLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // ----- Headings -----
  /// Large heading — used for screen titles
  static TextStyle headingLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Medium heading — used for section titles (e.g., "My Accounts")
  static TextStyle headingMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Small heading — used for card titles
  static TextStyle headingSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ----- Body Text -----
  /// Normal body text
  static TextStyle bodyLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Smaller body text
  static TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Very small text — used for dates, hints, metadata
  static TextStyle bodySmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  // ----- Labels -----
  /// Used for form labels above input fields
  static TextStyle labelLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  /// Used for badges and chips
  static TextStyle labelSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // ----- Button Text -----
  /// Text inside large action buttons
  static TextStyle buttonLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ----- Amount / Number styles -----
  /// For showing credit amounts in green
  static TextStyle amountCredit = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.credit,
  );

  /// For showing debit amounts in red
  static TextStyle amountDebit = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.debit,
  );
}
