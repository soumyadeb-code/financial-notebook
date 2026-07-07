// ============================================================
// history_screen.dart
// Full transaction history with:
//   • Bank-wise filter (All Banks + individual bank dropdown)
//   • Date range filter (From → To date pickers)
//   • Timeline grouping: Month banner → Day header → Transactions
//   • Category name highlighted as a colored chip
//   • Bank name + Contact name highlighted as accent chips
//   • Swipe-to-delete with balance reversal confirmation
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/bank/bank_bloc.dart';
import '../../../blocs/bank/bank_event.dart';
import '../../../blocs/bank/bank_state.dart';
import '../../../blocs/category/category_bloc.dart';
import '../../../blocs/category/category_state.dart';
import '../../../blocs/contact/contact_bloc.dart';
import '../../../blocs/contact/contact_state.dart';
import '../../../blocs/transaction/transaction_bloc.dart';
import '../../../blocs/transaction/transaction_event.dart';
import '../../../blocs/transaction/transaction_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/bank_model.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/models/transaction_model.dart';

// ── Sentinel values for "All Banks" selection ──────────────────
const _kAllBanks = 'ALL';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Filter state
  String _selectedBankId = _kAllBanks; // 'ALL' or a specific bank id
  String _searchQuery = '';
  DateTime? _fromDate;
  DateTime? _toDate;

  // ── Filter helpers ─────────────────────────────────────────

  /// Returns true if [txn] passes the current bank + date + contact filters.
  bool _passesFilter(TransactionModel txn, List<ContactModel> contacts) {
    // Bank filter
    if (_selectedBankId != _kAllBanks &&
        txn.bankId != _selectedBankId &&
        txn.transferToBankId != _selectedBankId) {
      return false;
    }
    // Date from filter
    if (_fromDate != null) {
      final from = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
      if (txn.date.isBefore(from)) return false;
    }
    // Date to filter (inclusive — end of day)
    if (_toDate != null) {
      final to = DateTime(
          _toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59);
      if (txn.date.isAfter(to)) return false;
    }
    // Contact filter
    if (_searchQuery.isNotEmpty) {
      if (txn.contactId == null) return false;
      final contact = contacts.where((c) => c.id == txn.contactId).firstOrNull;
      if (contact == null || !contact.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
    }
    return true;
  }

  /// Builds a mixed list of section headers and transactions for the ListView.
  /// Structure: _MonthHeader → _DayHeader → TransactionModel → ...
  List<dynamic> _buildSections(List<TransactionModel> all, List<ContactModel> contacts) {
    final filtered = all.where((t) => _passesFilter(t, contacts)).toList();

    final result = <dynamic>[];
    String? lastMonth;
    String? lastDay;

    for (final txn in filtered) {
      final monthKey = _monthKey(txn.date);   // e.g. "July 2026"
      final dayKey   = _dayKey(txn.date);     // e.g. "06 Jul"

      if (monthKey != lastMonth) {
        result.add(_MonthHeader(monthKey));   // Month banner
        lastMonth = monthKey;
        lastDay = null;                        // Reset day tracker
      }
      if (dayKey != lastDay) {
        result.add(_DayHeader(txn.date));     // Day separator
        lastDay = dayKey;
      }
      result.add(txn);
    }
    return result;
  }

  String _monthKey(DateTime d) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _dayKey(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month}-${d.year}';

  // ── Date pickers ───────────────────────────────────────────

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _toDate ?? DateTime.now(),
      builder: (_, child) => _darkDatePicker(child!),
    );
    if (picked != null) setState(() => _fromDate = picked);
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2000),
      lastDate: DateTime.now(),
      builder: (_, child) => _darkDatePicker(child!),
    );
    if (picked != null) setState(() => _toDate = picked);
  }

  Widget _darkDatePicker(Widget child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme:
              ColorScheme.dark(primary: AppColors.accent),
        ),
        child: child,
      );

  void _clearFilters() {
    setState(() {
      _selectedBankId = _kAllBanks;
      _searchQuery = '';
      _fromDate = null;
      _toDate = null;
    });
    FocusScope.of(context).unfocus();
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, contactState) {
        final contacts = contactState is ContactLoaded ? contactState.contacts : <ContactModel>[];
        return BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, txnState) {
            if (txnState is TransactionLoading) {
              return Center(
                  child: CircularProgressIndicator(color: AppColors.accent));
            }

            final transactions = txnState is TransactionLoaded
                ? txnState.transactions
                : <TransactionModel>[];

            return Column(
              children: [
                // ----- Filter Bar -----
                _buildFilterBar(context, transactions),

                // ----- Transaction List -----
                Expanded(
                  child: transactions.isEmpty
                      ? _buildEmptyState()
                      : _buildList(transactions, contacts),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(AppStrings.noTransactions, style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildList(List<TransactionModel> all, List<ContactModel> contacts) {
    final sections = _buildSections(all, contacts);
    if (sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('No transactions match\nyour current filters',
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _clearFilters,
              child: Text('Clear Filters',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.accent)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: sections.length,
      itemBuilder: (_, i) {
        final item = sections[i];
        if (item is _MonthHeader) return item;
        if (item is _DayHeader)   return item;
        return _TransactionCard(transaction: item as TransactionModel);
      },
    );
  }

  // ── Filter Bar ─────────────────────────────────────────────

  Widget _buildFilterBar(
      BuildContext context, List<TransactionModel> transactions) {
    final bool hasFilters =
        _selectedBankId != _kAllBanks || _fromDate != null || _toDate != null;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          // Row 1: Search bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _searchQuery.isNotEmpty ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: AppTextStyles.bodySmall,
                    decoration: InputDecoration(
                      hintText: 'Search by contact name...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                      prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textHint),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // adjusted vertical padding for 40 height
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Bank filter + Clear button
          Row(
            children: [
              Expanded(child: _buildBankFilter(context)),
              if (hasFilters) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _clearFilters,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.debit.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.close,
                            size: 14, color: AppColors.debit),
                        const SizedBox(width: 4),
                        Text('Clear',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.debit)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: Date range pickers
          Row(
            children: [
              Expanded(child: _buildDateChip(
                label: _fromDate == null
                    ? 'From Date'
                    : _fmtDate(_fromDate!),
                icon: Icons.calendar_today_outlined,
                active: _fromDate != null,
                onTap: _pickFromDate,
              )),
              const SizedBox(width: 8),
              Text('→',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Expanded(child: _buildDateChip(
                label: _toDate == null
                    ? 'To Date'
                    : _fmtDate(_toDate!),
                icon: Icons.calendar_today_outlined,
                active: _toDate != null,
                onTap: _pickToDate,
              )),
            ],
          ),
          const SizedBox(height: 8),

          // Divider
          Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_shortMonth(d.month)} ${d.year}';

  String _shortMonth(int m) => const [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ][m - 1];

  Widget _buildDateChip({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? AppColors.accent.withOpacity(0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 13,
                color: active ? AppColors.accent : AppColors.textHint),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: active ? AppColors.accent : AppColors.textSecondary,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankFilter(BuildContext context) {
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, state) {
        final banks = state is BankLoaded ? state.banks : <BankModel>[];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _selectedBankId != _kAllBanks
                  ? AppColors.accent
                  : AppColors.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBankId,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textPrimary),
              icon: Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary, size: 18),
              items: [
                // "All Banks" option
                DropdownMenuItem(
                  value: _kAllBanks,
                  child: Row(children: [
                    const Text('🏦', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('All Banks', style: AppTextStyles.bodySmall),
                  ]),
                ),
                // One entry per bank
                ...banks.map((bank) => DropdownMenuItem(
                      value: bank.id,
                      child: Row(children: [
                        const Text('💳', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(bank.name,
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    )),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedBankId = val);
              },
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// _MonthHeader — "July 2026" banner shown once per month
// ============================================================
class _MonthHeader extends StatelessWidget {
  final String label; // e.g. "July 2026"
  const _MonthHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ============================================================
// _DayHeader — "Mon, 07 Jul" separator between days
// ============================================================
class _DayHeader extends StatelessWidget {
  final DateTime date;
  const _DayHeader(this.date);

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final dayName = days[date.weekday - 1];
    final dayNum  = date.day.toString().padLeft(2, '0');
    final monName = months[date.month - 1];

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Row(
        children: [
          // Colored day badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Text(
              '$dayName, $dayNum $monName',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Thin line to the right
          Expanded(
            child: Divider(color: AppColors.border, height: 1),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// _TransactionCard — one transaction row with highlighted chips
// ============================================================
class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, bankState) {
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, catState) {
            return BlocBuilder<ContactBloc, ContactState>(
              builder: (context, contactState) {
                // Look up related data by ID
                final bank = bankState is BankLoaded
                    ? bankState.banks
                        .where((b) => b.id == transaction.bankId)
                        .firstOrNull
                    : null;

                final toBank = bankState is BankLoaded &&
                        transaction.transferToBankId != null
                    ? bankState.banks
                        .where((b) => b.id == transaction.transferToBankId)
                        .firstOrNull
                    : null;

                final category = catState is CategoryLoaded &&
                        transaction.categoryId != null
                    ? catState.categories
                        .where((c) => c.id == transaction.categoryId)
                        .firstOrNull
                    : null;

                final contact = contactState is ContactLoaded &&
                        transaction.contactId != null
                    ? contactState.contacts
                        .where((c) => c.id == transaction.contactId)
                        .firstOrNull
                    : null;

                // Type styling
                final Color typeColor;
                final String typeEmoji;
                switch (transaction.type) {
                  case TransactionType.credit:
                    typeColor = AppColors.credit;
                    typeEmoji = category?.emoji ?? '💚';
                    break;
                  case TransactionType.debit:
                    typeColor = AppColors.debit;
                    typeEmoji = category?.emoji ?? '🔴';
                    break;
                  case TransactionType.transfer:
                    typeColor = AppColors.transfer;
                    typeEmoji = '🔄';
                    break;
                }

                // Amount prefix: transfer shows neither + nor -
                final String amountPrefix =
                    transaction.type == TransactionType.transfer
                        ? ''
                        : transaction.type == TransactionType.credit
                            ? '+'
                            : '-';

                return Dismissible(
                  key: Key(transaction.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.debit.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.delete_outline,
                        color: AppColors.debit),
                  ),
                  confirmDismiss: (_) => _confirmDelete(context),
                  onDismissed: (_) {
                    context
                        .read<TransactionBloc>()
                        .add(DeleteTransaction(transaction));
                    context.read<BankBloc>().add(const RefreshBanks());
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: emoji + title + amount
                        Row(
                          children: [
                            // Category emoji badge
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(typeEmoji,
                                  style: const TextStyle(fontSize: 20)),
                            ),
                            const SizedBox(width: 10),

                            // Title (category name)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category name / transaction type label
                                  Text(
                                    category?.name ??
                                        (transaction.type ==
                                                TransactionType.transfer
                                            ? 'Transfer'
                                            : transaction.type ==
                                                    TransactionType.credit
                                                ? 'Credit'
                                                : 'Debit'),
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Optional note
                                  if (transaction.note != null &&
                                      transaction.note!.isNotEmpty)
                                    Text(
                                      transaction.note!,
                                      style: AppTextStyles.bodySmall.copyWith(
                                          fontStyle: FontStyle.italic),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Amount
                            Text(
                              '$amountPrefix${CurrencyFormatter.format(transaction.amount)}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Bottom chip row: category • bank • contact (transfer→)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            // ── Category chip ──────────────────
                            if (category != null)
                              _Chip(
                                label: '${category.emoji} ${category.name}',
                                color: Color(category.colorValue),
                              ),

                            // ── Bank name chip ─────────────────
                            if (bank != null)
                              _Chip(
                                label: '🏦 ${bank.name}',
                                color: const Color(0xFF3B82F6),
                              ),

                            // ── Transfer → destination bank ────
                            if (toBank != null)
                              _Chip(
                                label: '→ ${toBank.name}',
                                color: AppColors.transfer,
                              ),

                            // ── Contact chip ───────────────────
                            if (contact != null)
                              _Chip(
                                label: '👤 ${contact.name}',
                                color: const Color(0xFF8B5CF6),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Transaction?',
            style: AppTextStyles.headingSmall),
        content: Text(
          'This transaction will be deleted and the bank balance will be reversed.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style:
                    AppTextStyles.bodyLarge.copyWith(color: AppColors.debit)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// _Chip — small colored label chip for category / bank / contact
// ============================================================
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
