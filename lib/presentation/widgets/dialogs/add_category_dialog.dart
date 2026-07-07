// ============================================================
// add_category_dialog.dart
// Bottom sheet to add a new spending/earning category.
// Includes an emoji picker grid and a color picker palette.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../blocs/category/category_bloc.dart';
import '../../../blocs/category/category_event.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/category_model.dart';
import '../common/app_button.dart';
import '../common/app_text_field.dart';

void showAddCategoryDialog(BuildContext context, {CategoryModel? categoryToEdit}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<CategoryBloc>(),
      child: _AddCategorySheet(categoryToEdit: categoryToEdit),
    ),
  );
}

class _AddCategorySheet extends StatefulWidget {
  final CategoryModel? categoryToEdit;
  const _AddCategorySheet({this.categoryToEdit});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '📦'; // Default emoji
  Color _selectedColor = AppColors.accent; // Default color
  String? _nameError;

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.name;
      _selectedEmoji = widget.categoryToEdit!.emoji;
      _selectedColor = Color(widget.categoryToEdit!.colorValue);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Text(_selectedEmoji, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.categoryToEdit != null ? 'Edit Category' : AppStrings.addCategory,
                  style: AppTextStyles.headingMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon:
                      Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Category Name Field
            AppTextField(
              label: AppStrings.categoryName,
              hint: 'e.g. Food, Transport, Movies',
              controller: _nameController,
              errorText: _nameError,
            ),
            const SizedBox(height: 20),

            // Emoji Picker
            Text(
              AppStrings.chooseEmoji.toUpperCase(),
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 10),
            _buildEmojiGrid(),
            const SizedBox(height: 20),

            // Color Picker
            Text(
              AppStrings.chooseColor.toUpperCase(),
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 10),
            _buildColorPalette(),
            const SizedBox(height: 28),

            AppButton(
              label: widget.categoryToEdit != null ? 'Save Changes' : AppStrings.addCategoryButton,
              onTap: _onAdd,
            ),
          ],
        ),
      ),
    );
  }

  /// A scrollable grid of emoji choices
  Widget _buildEmojiGrid() {
    return SizedBox(
      height: 140, // Fixed height for the scrollable grid
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: AppStrings.commonEmojis.length,
        itemBuilder: (context, index) {
          final emoji = AppStrings.commonEmojis[index];
          final isSelected = emoji == _selectedEmoji;
          return GestureDetector(
            onTap: () => setState(() => _selectedEmoji = emoji),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? _selectedColor.withOpacity(0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? _selectedColor : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          );
        },
      ),
    );
  }

  /// A row of color circles to pick from
  Widget _buildColorPalette() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppColors.categoryColors.map((color) {
        final isSelected = color.value == _selectedColor.value;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        );
      }).toList(),
    );
  }

  void _onAdd() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Please enter a category name');
      return;
    }

    if (widget.categoryToEdit != null) {
      final category = widget.categoryToEdit!.copyWith(
        name: _nameController.text.trim(),
        emoji: _selectedEmoji,
        colorValue: _selectedColor.value,
      );
      context.read<CategoryBloc>().add(UpdateCategory(category));
    } else {
      final category = CategoryModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        emoji: _selectedEmoji,
        colorValue: _selectedColor.value,
      );
      context.read<CategoryBloc>().add(AddCategory(category));
    }
    
    Navigator.pop(context);
  }
}
