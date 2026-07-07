// ============================================================
// add_bank_dialog.dart
// Bottom sheet dialog to add a new bank account.
// Fields: Bank Name, Account Type, Opening Balance, Date Added.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../blocs/bank/bank_bloc.dart';
import '../../../blocs/bank/bank_event.dart';
import '../../../blocs/user/user_bloc.dart';
import '../../../blocs/user/user_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/bank_model.dart';
import '../common/app_button.dart';
import '../common/app_text_field.dart';

/// Shows the Add Bank bottom sheet dialog.
/// Returns a Future that completes when the sheet is dismissed —
/// the caller can await this to trigger a data refresh.
Future<void> showAddBankDialog(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<BankBloc>(),
      child: BlocProvider.value(
        value: context.read<UserBloc>(),
        child: const _AddBankSheet(),
      ),
    ),
  );
}

class _AddBankSheet extends StatefulWidget {
  const _AddBankSheet();

  @override
  State<_AddBankSheet> createState() => _AddBankSheetState();
}

class _AddBankSheetState extends State<_AddBankSheet> {
  // Controllers hold the text the user types
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');

  // Selected values for dropdowns/pickers
  String _selectedType = AppStrings.accountTypes.first;
  DateTime _selectedDate = DateTime.now();

  // Validation
  String? _nameError;

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Adjust for keyboard height so fields aren't hidden
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
            // ----- Header -----
            _buildHeader(context),
            const SizedBox(height: 24),

            // ----- Bank Name -----
            AppTextField(
              label: AppStrings.bankName,
              hint: 'e.g. SBI, HDFC, ICICI',
              controller: _nameController,
              errorText: _nameError,
            ),
            const SizedBox(height: 16),

            // ----- Account Type Dropdown -----
            _buildTypeDropdown(),
            const SizedBox(height: 16),

            // ----- Opening Balance -----
            AppTextField(
              label: AppStrings.openingBalance,
              hint: '0.00',
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                // Only allow numbers and decimal point
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
            const SizedBox(height: 16),

            // ----- Date Picker -----
            _buildDatePicker(),
            const SizedBox(height: 28),

            // ----- Add Button -----
            AppButton(
              label: AppStrings.addBankButton,
              onTap: _onAdd,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Emoji icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('🏦', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 12),
        Text(AppStrings.addBank, style: AppTextStyles.headingMedium),
        const Spacer(),
        // Close button
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.accountType.toUpperCase(),
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: AppTextStyles.bodyLarge,
              items: AppStrings.accountTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return AppTextField(
      label: AppStrings.dateAdded,
      controller: TextEditingController(
          text: DateFormatter.toDisplay(_selectedDate)),
      readOnly: true, // User can only tap to open the date picker
      suffix: Icon(Icons.calendar_today_outlined,
          color: AppColors.textSecondary, size: 18),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (_, child) => Theme(
            // Dark theme for the date picker
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(primary: AppColors.accent),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
    );
  }

  void _onAdd() {
    // Validate bank name
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Please enter a bank name');
      return;
    }

    // Get the user's name for the owner field
    final userState = context.read<UserBloc>().state;
    final ownerName =
        userState is UserAuthenticated ? userState.name : 'You';

    // Parse the opening balance
    final balance = double.tryParse(_balanceController.text) ?? 0.0;

    // Create the BankModel
    final bank = BankModel(
      id: const Uuid().v4(), // Generate a unique ID
      name: _nameController.text.trim(),
      accountType: _selectedType,
      openingBalance: balance,
      currentBalance: balance, // Current balance starts at opening balance
      dateAdded: _selectedDate,
      ownerName: ownerName,
    );

    // Send the AddBank event to the BankBloc
    context.read<BankBloc>().add(AddBank(bank));

    // Close the dialog
    Navigator.pop(context);
  }
}
