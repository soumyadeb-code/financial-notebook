// ============================================================
// transfer_dialog.dart
// Bottom sheet for transferring money between two accounts.
// Fields: From account, To account, Amount, Note, Date.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../blocs/bank/bank_bloc.dart';
import '../../../blocs/bank/bank_event.dart';
import '../../../blocs/bank/bank_state.dart';
import '../../../blocs/transaction/transaction_bloc.dart';
import '../../../blocs/transaction/transaction_event.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/bank_model.dart';
import '../../../data/models/transaction_model.dart';
import '../common/app_button.dart';
import '../common/app_text_field.dart';

void showTransferDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<TransactionBloc>()),
        BlocProvider.value(value: context.read<BankBloc>()),
      ],
      child: const _TransferSheet(),
    ),
  );
}

class _TransferSheet extends StatefulWidget {
  const _TransferSheet();

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _fromBankId;
  String? _toBankId;
  DateTime _selectedDate = DateTime.now();
  String? _amountError;
  String? _bankError;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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
        child: BlocBuilder<BankBloc, BankState>(
          builder: (context, state) {
            final banks =
                state is BankLoaded ? state.banks : <BankModel>[];

            // Auto-select banks if not already selected
            if (_fromBankId == null && banks.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _fromBankId = banks[0].id;
                  _toBankId = banks.length >= 2 ? banks[1].id : null;
                });
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          const Text('🔄', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Text(AppStrings.transferMoney,
                        style: AppTextStyles.headingMedium),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // From Account
                _buildAccountDropdown(
                  label: AppStrings.fromAccount,
                  banks: banks,
                  selectedId: _fromBankId,
                  onChanged: (val) => setState(() => _fromBankId = val),
                ),
                const SizedBox(height: 12),

                // "Transfer To" arrow in the middle
                Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_downward,
                        color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(height: 12),

                // To Account
                _buildAccountDropdown(
                  label: AppStrings.toAccount,
                  banks: banks.where((b) => b.id != _fromBankId).toList(),
                  selectedId: _toBankId,
                  onChanged: (val) => setState(() => _toBankId = val),
                ),
                if (_bankError != null) ...[
                  const SizedBox(height: 4),
                  Text(_bankError!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.debit)),
                ],
                const SizedBox(height: 16),

                // Amount
                AppTextField(
                  label: 'Amount (₹)',
                  hint: '0.00',
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  errorText: _amountError,
                ),
                const SizedBox(height: 16),

                // Note
                AppTextField(
                  label: AppStrings.note,
                  hint: AppStrings.transferNote,
                  controller: _noteController,
                ),
                const SizedBox(height: 16),

                // Date
                _buildDatePicker(),
                const SizedBox(height: 28),

                // Transfer Now button (green)
                AppButton(
                  label: AppStrings.transferNowButton,
                  color: AppColors.credit,
                  prefixIcon: const Text('🔄',
                      style: TextStyle(fontSize: 16)),
                  onTap: _onTransfer,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountDropdown({
    required String label,
    required List<BankModel> banks,
    required String? selectedId,
    required ValueChanged<String?> onChanged,
  }) {
    // Ensure the selected ID still exists in the provided list
    if (selectedId != null && !banks.any((b) => b.id == selectedId)) {
      selectedId = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.labelLarge),
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
              value: selectedId,
              isExpanded: true,
              hint: Text('Select account', style: AppTextStyles.bodyMedium),
              dropdownColor: AppColors.surface,
              style: AppTextStyles.bodyLarge,
              items: banks
                  .map((bank) => DropdownMenuItem(
                        value: bank.id,
                        child: Text(bank.displayName),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return AppTextField(
      label: AppStrings.date,
      controller: TextEditingController(
          text: DateFormatter.toDisplay(_selectedDate)),
      readOnly: true,
      suffix: Icon(Icons.calendar_today_outlined,
          color: AppColors.textSecondary, size: 18),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (_, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme:
                  ColorScheme.dark(primary: AppColors.accent),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
    );
  }

  void _onTransfer() {
    // Validation
    setState(() {
      _amountError = null;
      _bankError = null;
    });

    if (_fromBankId == null || _toBankId == null) {
      setState(() => _bankError = 'Please select both accounts');
      return;
    }

    if (_fromBankId == _toBankId) {
      setState(() => _bankError = 'From and To accounts must be different');
      return;
    }

    final amountStr = _amountController.text.trim();
    if (amountStr.isEmpty || double.tryParse(amountStr) == null) {
      setState(() => _amountError = 'Enter a valid amount');
      return;
    }

    final amount = double.parse(amountStr);
    if (amount <= 0) {
      setState(() => _amountError = 'Amount must be greater than 0');
      return;
    }

    // Create a Transfer transaction
    final txn = TransactionModel(
      id: const Uuid().v4(),
      bankId: _fromBankId!,                    // Money leaves from here
      type: TransactionType.transfer,
      amount: amount,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      date: _selectedDate,
      transferToBankId: _toBankId!,             // Money arrives here
    );

    // Dispatch to TransactionBloc (which updates both bank balances)
    context.read<TransactionBloc>().add(AddTransaction(txn));

    // Refresh bank balances in BankBloc
    context.read<BankBloc>().add(const RefreshBanks());

    Navigator.pop(context);
  }
}
