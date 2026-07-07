// ============================================================
// add_transaction_dialog.dart
// Bottom sheet to add a Credit or Debit transaction.
// Features: bank dropdown, credit/debit toggle, amount,
//           searchable contact, searchable category, note, date.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../blocs/bank/bank_bloc.dart';
import '../../../blocs/bank/bank_event.dart';
import '../../../blocs/bank/bank_state.dart';
import '../../../blocs/category/category_bloc.dart';
import '../../../blocs/category/category_state.dart';
import '../../../blocs/contact/contact_bloc.dart';
import '../../../blocs/contact/contact_event.dart';
import '../../../blocs/contact/contact_state.dart';
import '../../../blocs/transaction/transaction_bloc.dart';
import '../../../blocs/transaction/transaction_event.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/bank_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/models/transaction_model.dart';
import '../common/app_button.dart';
import '../common/app_text_field.dart';

void showAddTransactionDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<TransactionBloc>()),
        BlocProvider.value(value: context.read<BankBloc>()),
        BlocProvider.value(value: context.read<ContactBloc>()),
        BlocProvider.value(value: context.read<CategoryBloc>()),
      ],
      child: const _AddTransactionSheet(),
    ),
  );
}

class _AddTransactionSheet extends StatefulWidget {
  const _AddTransactionSheet();

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _contactSearchController = TextEditingController();
  final _categorySearchController = TextEditingController();
  late final TextEditingController _dateController;

  // Selected values
  String? _selectedBankId;
  TransactionType _selectedType = TransactionType.credit;
  ContactModel? _selectedContact;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  // Search results (filtered lists)
  List<ContactModel> _filteredContacts = [];
  List<CategoryModel> _filteredCategories = [];

  // Show/hide dropdown lists
  bool _showContactList = false;
  bool _showCategoryList = false;

  String? _amountError;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: DateFormatter.toDisplay(_selectedDate));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _contactSearchController.dispose();
    _categorySearchController.dispose();
    _dateController.dispose();
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
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildBankDropdown(),
            const SizedBox(height: 16),
            _buildTypeToggle(),
            const SizedBox(height: 16),
            AppTextField(
              label: '${AppStrings.amount} (₹)',
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
            _buildContactSearch(),
            const SizedBox(height: 16),
            _buildCategorySearch(),
            const SizedBox(height: 16),
            AppTextField(
              label: AppStrings.note,
              hint: AppStrings.optionalNote,
              controller: _noteController,
            ),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 28),
            AppButton(
              label: AppStrings.addTransactionButton,
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('💳', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 12),
        Text(AppStrings.addTransaction, style: AppTextStyles.headingMedium),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Dropdown to select which bank account this transaction belongs to
  Widget _buildBankDropdown() {
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, state) {
        final banks = state is BankLoaded ? state.banks : <BankModel>[];
        if (_selectedBankId == null && banks.isNotEmpty) {
          // Auto-select first bank
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _selectedBankId = banks.first.id);
          });
        }
        
        // Ensure selected ID still exists
        if (_selectedBankId != null && !banks.any((b) => b.id == _selectedBankId)) {
          _selectedBankId = null;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.bankAccount.toUpperCase(),
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
                  value: _selectedBankId,
                  isExpanded: true,
                  hint: Text('Select account',
                      style: AppTextStyles.bodyMedium),
                  dropdownColor: AppColors.surface,
                  style: AppTextStyles.bodyLarge,
                  items: banks
                      .map((bank) => DropdownMenuItem(
                            value: bank.id,
                            child: Text(bank.displayName),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBankId = val),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Toggle between Credit and Debit
  Widget _buildTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.transactionType.toUpperCase(),
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TypeButton(
                label: AppStrings.credit,
                icon: '💚',
                isSelected: _selectedType == TransactionType.credit,
                selectedColor: AppColors.credit,
                onTap: () => setState(
                    () => _selectedType = TransactionType.credit),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TypeButton(
                label: AppStrings.debit,
                icon: '🔴',
                isSelected: _selectedType == TransactionType.debit,
                selectedColor: AppColors.debit,
                onTap: () =>
                    setState(() => _selectedType = TransactionType.debit),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Contact search with live filtering
  Widget _buildContactSearch() {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        final allContacts =
            state is ContactLoaded ? state.contacts : <ContactModel>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label with "optional" badge
            Row(
              children: [
                Text(
                  AppStrings.contact.toUpperCase(),
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(AppStrings.optional,
                      style: AppTextStyles.labelSmall),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Show selected contact chip or search field
            if (_selectedContact != null)
              _buildSelectedChip(
                label: _selectedContact!.name,
                onRemove: () {
                  setState(() {
                    _selectedContact = null;
                    _contactSearchController.clear();
                  });
                },
              )
            else
              TextField(
                controller: _contactSearchController,
                style: AppTextStyles.bodyLarge,
                onChanged: (query) {
                  setState(() {
                    _showContactList = query.isNotEmpty;
                    _filteredContacts = allContacts
                        .where((c) => c.name
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: AppStrings.searchContact,
                  hintStyle: AppTextStyles.bodyMedium,
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            // Dropdown list of matching contacts
            if (_showContactList && _filteredContacts.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredContacts.isEmpty ? 1 : _filteredContacts.length.clamp(0, 4) + 1,
                  itemBuilder: (_, i) {
                    // Show "Add new contact" if no matches or at the end of the list
                    final query = _contactSearchController.text.trim();
                    final exactMatchExists = _filteredContacts.any((c) => c.name.toLowerCase() == query.toLowerCase());
                    
                    if (i == _filteredContacts.length.clamp(0, 4) || _filteredContacts.isEmpty) {
                      if (query.isNotEmpty && !exactMatchExists) {
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.credit,
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                          title: Text('Add "$query"', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.credit)),
                          onTap: () {
                            // Create and select new contact immediately
                            final newContact = ContactModel(id: const Uuid().v4(), name: query);
                            context.read<ContactBloc>().add(AddContact(newContact));
                            
                            setState(() {
                              _selectedContact = newContact;
                              _showContactList = false;
                              _contactSearchController.text = newContact.name;
                            });
                          },
                        );
                      }
                      return const SizedBox(); // Hide if query is empty or exact match exists
                    }
                    
                    final c = _filteredContacts[i];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.accent,
                        child: Text(c.initials,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ),
                      title: Text(c.name, style: AppTextStyles.bodyLarge),
                      onTap: () {
                        setState(() {
                          _selectedContact = c;
                          _showContactList = false;
                          _contactSearchController.text = c.name;
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  /// Category search with live filtering
  Widget _buildCategorySearch() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final allCategories =
            state is CategoryLoaded ? state.categories : <CategoryModel>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.category.toUpperCase(),
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 8),
            if (_selectedCategory != null)
              _buildSelectedChip(
                label: _selectedCategory!.displayLabel,
                color: _selectedCategory!.color,
                onRemove: () {
                  setState(() {
                    _selectedCategory = null;
                    _categorySearchController.clear();
                  });
                },
              )
            else
              TextField(
                controller: _categorySearchController,
                style: AppTextStyles.bodyLarge,
                onChanged: (query) {
                  setState(() {
                    _showCategoryList = query.isNotEmpty;
                    _filteredCategories = allCategories
                        .where((c) => c.name
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: AppStrings.searchCategory,
                  hintStyle: AppTextStyles.bodyMedium,
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            if (_showCategoryList && _filteredCategories.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredCategories.length.clamp(0, 4),
                  itemBuilder: (_, i) {
                    final cat = _filteredCategories[i];
                    return ListTile(
                      dense: true,
                      leading: Text(cat.emoji,
                          style: const TextStyle(fontSize: 20)),
                      title: Text(cat.name, style: AppTextStyles.bodyLarge),
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                          _showCategoryList = false;
                          _categorySearchController.text = cat.displayLabel;
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  /// A chip showing selected item with a remove button
  Widget _buildSelectedChip({
    required String label,
    Color? color,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? AppColors.accent).withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color ?? AppColors.accent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.bodyLarge),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close,
                size: 16, color: color ?? AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return AppTextField(
      label: AppStrings.date,
      controller: _dateController,
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
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _dateController.text = DateFormatter.toDisplay(picked);
          });
        }
      },
    );
  }

  void _onAdd() {
    setState(() => _amountError = null);

    if (_selectedBankId == null) {
      setState(() => _amountError = 'Please select a bank account');
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

    final txn = TransactionModel(
      id: const Uuid().v4(),
      bankId: _selectedBankId!,
      type: _selectedType,
      amount: amount,
      contactId: _selectedContact?.id,
      categoryId: _selectedCategory?.id,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      date: _selectedDate,
    );

    // Add transaction (this also updates bank balance)
    context.read<TransactionBloc>().add(AddTransaction(txn));

    // Refresh bank balances in UI
    context.read<BankBloc>().add(const RefreshBanks());

    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }
}

/// Credit / Debit toggle button
class _TypeButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isSelected ? selectedColor : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
