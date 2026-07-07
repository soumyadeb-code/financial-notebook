// ============================================================
// app_button.dart
// A reusable button widget used throughout the app.
// Supports primary (filled) and secondary (outlined) styles.
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap; // null = button is disabled
  final bool isLoading;      // Shows a spinner when true
  final bool isSecondary;    // Outlined style instead of filled
  final Color? color;        // Override button color
  final Widget? prefixIcon;  // Icon before the label
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isSecondary = false,
    this.color,
    this.prefixIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.accent;

    return SizedBox(
      width: width ?? double.infinity, // Full width by default
      height: 54,
      child: isSecondary
          ? _buildOutlinedButton(buttonColor)
          : _buildFilledButton(buttonColor),
    );
  }

  Widget _buildFilledButton(Color buttonColor) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        disabledBackgroundColor: buttonColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: _buildContent(AppColors.textPrimary),
    );
  }

  Widget _buildOutlinedButton(Color buttonColor) {
    return OutlinedButton(
      onPressed: isLoading ? null : onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: buttonColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: _buildContent(buttonColor),
    );
  }

  Widget _buildContent(Color textColor) {
    if (isLoading) {
      // Show a circular loading indicator when loading
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          prefixIcon!,
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTextStyles.buttonLarge.copyWith(color: textColor),
        ),
      ],
    );
  }
}
