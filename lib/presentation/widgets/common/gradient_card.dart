// ============================================================
// gradient_card.dart
// A card with a gradient background.
// Used for the Net Worth card on the home screen.
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        // Use provided gradient or default purple gradient
        gradient: gradient ?? AppColors.purpleGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
