// ============================================================
// contact_item.dart
// A single contact shown in the contacts list.
// Shows initials avatar and name.
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/contact_model.dart';

class ContactItem extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback? onDelete;

  const ContactItem({
    super.key,
    required this.contact,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // ----- Avatar with initials -----
          CircleAvatar(
            radius: 22,
            backgroundColor: _avatarColor(contact.name),
            child: Text(
              contact.initials,
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ----- Name -----
          Expanded(
            child: Text(
              contact.name,
              style: AppTextStyles.bodyLarge,
            ),
          ),

          // ----- Delete Icon -----
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.debit.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.debit,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Generate a consistent color from the contact's name
  Color _avatarColor(String name) {
    final colors = [
      AppColors.accent,
      const Color(0xFF22C55E),
      const Color(0xFF3B82F6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
    ];
    // Use the sum of character codes to pick a consistent color
    final index = name.codeUnits.fold(0, (sum, c) => sum + c) % colors.length;
    return colors[index];
  }
}
