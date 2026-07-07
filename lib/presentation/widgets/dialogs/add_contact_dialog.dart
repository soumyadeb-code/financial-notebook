// ============================================================
// add_contact_dialog.dart
// Bottom sheet to add a new contact.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../blocs/contact/contact_bloc.dart';
import '../../../blocs/contact/contact_event.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/contact_model.dart';
import '../common/app_button.dart';
import '../common/app_text_field.dart';

void showAddContactDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<ContactBloc>(),
      child: const _AddContactSheet(),
    ),
  );
}

class _AddContactSheet extends StatefulWidget {
  const _AddContactSheet();

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _nameController = TextEditingController();
  String? _nameError;

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('👤', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Text(AppStrings.addContact, style: AppTextStyles.headingMedium),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          AppTextField(
            label: AppStrings.contactName,
            hint: 'e.g. Arya Sir, Mom, Netflix',
            controller: _nameController,
            errorText: _nameError,
          ),
          const SizedBox(height: 28),

          AppButton(
            label: AppStrings.addContactButton,
            onTap: _onAdd,
          ),
        ],
      ),
    );
  }

  void _onAdd() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Please enter a name');
      return;
    }

    final contact = ContactModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
    );

    context.read<ContactBloc>().add(AddContact(contact));
    Navigator.pop(context);
  }
}
