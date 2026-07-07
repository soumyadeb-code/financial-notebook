// ============================================================
// category_chip.dart
// A single category item in the category grid.
// Shows emoji, name, and color swatch.
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const CategoryChip({
    super.key,
    required this.category,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // ----- Emoji Icon -----
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              category.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 10),

          // ----- Name + Color -----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: AppTextStyles.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Show the hex color value
                Text(
                  '#${category.colorValue.toRadixString(16).substring(2).toUpperCase()}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: category.color,
                  ),
                ),
              ],
            ),
          ),

          // ----- Edit Icon -----
          if (onEdit != null) ...[
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.accent,
                  size: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // ----- Delete Icon -----
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.debit.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.debit,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
