// ============================================================
// app_text_field.dart
// A styled text input field used throughout the app.
// Wraps Flutter's TextField with our custom theme.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;           // For password/PIN fields
  final bool readOnly;              // For date pickers (tap only)
  final Widget? suffix;             // Widget at the right end
  final Widget? prefix;            // Widget at the left end
  final int? maxLines;
  final int? maxLength;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.suffix,
    this.prefix,
    this.maxLines = 1,
    this.maxLength,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the field (e.g., "BANK NAME")
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 8),
        // The actual text input
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          onTap: onTap,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            prefixIcon: prefix,
            errorText: errorText,
            counterText: '', // Hide the character counter
          ),
        ),
      ],
    );
  }
}
