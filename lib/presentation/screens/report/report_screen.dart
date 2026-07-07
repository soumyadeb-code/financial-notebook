// ============================================================
// report_screen.dart
// Shows spending analytics:
//   - Summary cards (Total In, Total Out, Net)
//   - Bar chart of spending by category
//   - Period selector: Week / Month / Year
// Uses fl_chart for the bar chart.
// ============================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/bank/bank_bloc.dart';
import '../../../blocs/bank/bank_state.dart';
import '../../../blocs/category/category_bloc.dart';
import '../../../blocs/category/category_state.dart';
import '../../../blocs/contact/contact_bloc.dart';
import '../../../blocs/contact/contact_state.dart';
import '../../../blocs/transaction/transaction_bloc.dart';
import '../../../blocs/transaction/transaction_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/models/transaction_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // Mode selector
  bool _isDailyTracker = false;
  // Period selector (Overview mode)
  String _selectedPeriod = AppStrings.week;
  // Date selector (Daily Tracker mode)
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, txnState) {
          if (txnState is! TransactionLoaded) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          // Filter for overview mode
          final overviewFiltered = _filterByPeriod(txnState.transactions);
          final totalIn = overviewFiltered.where((t) => t.type == TransactionType.credit).fold(0.0, (sum, t) => sum + t.amount);
          final totalOut = overviewFiltered.where((t) => t.type == TransactionType.debit).fold(0.0, (sum, t) => sum + t.amount);

          // Filter for daily mode
          final openingDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day - 1, 23, 59, 59);
          final closingDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
          final dailyFiltered = txnState.transactions.where((t) => t.date.isAfter(openingDate) && t.date.isBefore(closingDate)).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopToggle(),
                const SizedBox(height: 20),

                if (_isDailyTracker) ...[
                  _buildDailyTrackerHeader(),
                  const SizedBox(height: 20),
                  _buildDailySummaryRow(txnState.transactions),
                  const SizedBox(height: 24),
                  _buildDailyBankBalances(txnState.transactions),
                  const SizedBox(height: 24),
                  _buildCategoryChart(dailyFiltered),
                  const SizedBox(height: 24),
                  _buildContactChart(dailyFiltered),
                ] else ...[
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),
                  _buildSummaryRow(totalIn, totalOut),
                  const SizedBox(height: 24),
                  _buildPeriodOverviewChart(txnState.transactions),
                  const SizedBox(height: 24),
                  _buildCategoryChart(overviewFiltered),
                  const SizedBox(height: 24),
                  _buildContactChart(overviewFiltered),
                ],
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Mode Toggle ────────────────────────────────────────────────
  Widget _buildTopToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isDailyTracker = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isDailyTracker ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month, size: 16, color: !_isDailyTracker ? Colors.white : AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Overview',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: !_isDailyTracker ? Colors.white : AppColors.textSecondary,
                        fontWeight: !_isDailyTracker ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isDailyTracker = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isDailyTracker ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: _isDailyTracker ? Colors.white : AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Tracker',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _isDailyTracker ? Colors.white : AppColors.textSecondary,
                        fontWeight: _isDailyTracker ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Daily Tracker specific widgets ──────────────────────────────
  Widget _buildDailyTrackerHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SELECT DATE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textHint)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    builder: (context, child) => Theme(
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('Auto-saves 12:00 AM IST', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailySummaryRow(List<TransactionModel> transactions) {
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, bankState) {
        if (bankState is! BankLoaded) return const SizedBox();

        final openingDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day - 1, 23, 59, 59);
        final closingDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
        final beginningOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

        // Opening Balance calculation
        double initialBanks = bankState.banks.fold(0.0, (s, b) => s + b.openingBalance);
        double historicalNet = transactions
            .where((t) => t.date.isBefore(beginningOfDay))
            .fold(0.0, (sum, t) {
          if (t.type == TransactionType.credit) return sum + t.amount;
          if (t.type == TransactionType.debit) return sum - t.amount;
          return sum; // transfers don't change net worth
        });
        double openingBalance = initialBanks + historicalNet;

        // Daily transactions
        final dailyTxns = transactions.where((t) => t.date.isAfter(openingDate) && t.date.isBefore(closingDate)).toList();
        double dailyCredit = dailyTxns.where((t) => t.type == TransactionType.credit).fold(0.0, (s, t) => s + t.amount);
        double dailyDebit = dailyTxns.where((t) => t.type == TransactionType.debit).fold(0.0, (s, t) => s + t.amount);
        double saved = dailyCredit - dailyDebit;
        double closingBalance = openingBalance + saved;

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _SummaryCard(label: 'CREDIT', amount: dailyCredit, color: AppColors.credit, emoji: '📈')),
                const SizedBox(width: 8),
                Expanded(child: _SummaryCard(label: 'DEBIT', amount: dailyDebit, color: AppColors.debit, emoji: '📉')),
                const SizedBox(width: 8),
                Expanded(child: _SummaryCard(label: 'SAVED', amount: saved, color: saved >= 0 ? AppColors.credit : AppColors.debit, emoji: '💰')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _SummaryCard(label: 'OPENING', amount: openingBalance, color: const Color(0xFFEAB308), emoji: '◀️')),
                const SizedBox(width: 8),
                Expanded(child: _SummaryCard(label: 'CLOSING', amount: closingBalance, color: AppColors.accent, emoji: '▶️')),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDailyBankBalances(List<TransactionModel> transactions) {
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, state) {
        if (state is! BankLoaded || state.banks.isEmpty) return const SizedBox();

        final openingDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day - 1, 23, 59, 59);
        final closingDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
        
        // Calculate total closing balance for percentage
        double totalClosing = 0;
        final openingBalances = <String, double>{};
        final closingBalances = <String, double>{};
        
        for (final bank in state.banks) {
          // 1. Calculate opening balance
          double openBal = bank.openingBalance;
          final pastTxnsBeforeOpen = transactions.where((t) => t.date.isBefore(openingDate));
          for (final t in pastTxnsBeforeOpen) {
            if (t.bankId == bank.id) {
              if (t.type == TransactionType.credit) openBal += t.amount;
              if (t.type == TransactionType.debit) openBal -= t.amount;
              if (t.type == TransactionType.transfer) openBal -= t.amount;
            } else if (t.transferToBankId == bank.id) {
              openBal += t.amount;
            }
          }
          openingBalances[bank.id] = openBal;

          // 2. Calculate closing balance
          double closeBal = openBal;
          final dailyTxns = transactions.where((t) => t.date.isAfter(openingDate) && t.date.isBefore(closingDate));
          for (final t in dailyTxns) {
            if (t.bankId == bank.id) {
              if (t.type == TransactionType.credit) closeBal += t.amount;
              if (t.type == TransactionType.debit) closeBal -= t.amount;
              if (t.type == TransactionType.transfer) closeBal -= t.amount;
            } else if (t.transferToBankId == bank.id) {
              closeBal += t.amount;
            }
          }
          closingBalances[bank.id] = closeBal;
          if (closeBal > 0) totalClosing += closeBal;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Balances', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),
            ...state.banks.map((bank) {
              final openBal = openingBalances[bank.id] ?? 0.0;
              final closeBal = closingBalances[bank.id] ?? 0.0;
              final pct = totalClosing > 0 ? (closeBal / totalClosing).clamp(0.0, 1.0) : 0.0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(bank.name, style: AppTextStyles.bodyLarge),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Open: ${CurrencyFormatter.format(openBal)}',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              'Close: ${CurrencyFormatter.format(closeBal)}',
                              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.border,
                        color: AppColors.accent,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildContactChart(List<TransactionModel> transactions) {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        if (state is! ContactLoaded) return const SizedBox();

        // Only look at transactions with a contact
        final contactTxns = transactions.where((t) => t.contactId != null).toList();

        if (contactTxns.isEmpty) return const SizedBox();

        // Aggregate by contact
        final Map<String, double> contactCredit = {};
        final Map<String, double> contactDebit = {};
        
        for (final txn in contactTxns) {
          final cid = txn.contactId!;
          if (txn.type == TransactionType.credit) {
            contactCredit[cid] = (contactCredit[cid] ?? 0) + txn.amount;
          } else if (txn.type == TransactionType.debit) {
            contactDebit[cid] = (contactDebit[cid] ?? 0) + txn.amount;
          }
        }

        // Get top 6 contacts by total volume
        final allContactIds = {...contactCredit.keys, ...contactDebit.keys}.toList();
        allContactIds.sort((a, b) {
          final volA = (contactCredit[a] ?? 0) + (contactDebit[a] ?? 0);
          final volB = (contactCredit[b] ?? 0) + (contactDebit[b] ?? 0);
          return volB.compareTo(volA);
        });
        
        final top = allContactIds.take(6).toList();
        if (top.isEmpty) return const SizedBox();

        final barGroups = top.asMap().entries.map((e) {
          final cid = e.value;
          final credit = contactCredit[cid] ?? 0;
          final debit = contactDebit[cid] ?? 0;
          
          return BarChartGroupData(
            x: e.key,
            barRods: [
              if (credit > 0)
                BarChartRodData(
                  toY: credit,
                  color: AppColors.credit,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              if (debit > 0)
                BarChartRodData(
                  toY: debit,
                  color: AppColors.debit,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
            ],
          );
        }).toList();

        double maxY = 0.0;
        for (final cid in top) {
          final credit = contactCredit[cid] ?? 0;
          final debit = contactDebit[cid] ?? 0;
          if (credit > maxY) maxY = credit;
          if (debit > maxY) maxY = debit;
        }
        maxY = maxY == 0 ? 100 : maxY * 1.2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Flow by Contact', style: AppTextStyles.headingMedium),
            const SizedBox(height: 16),
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final i = val.toInt();
                          if (i >= top.length) return const SizedBox();
                          final cid = top[i];
                          final c = state.contacts.where((c) => c.id == cid).firstOrNull;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              c != null ? (c.name.length > 5 ? '${c.name.substring(0, 5)}.' : c.name) : '...',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppColors.surfaceLight,
                      getTooltipItem: (group, _, rod, __) {
                        final cid = top[group.x];
                        final c = state.contacts.where((c) => c.id == cid).firstOrNull;
                        final isCredit = rod.color == AppColors.credit;
                        return BarTooltipItem(
                          '${c?.name ?? 'Other'}\n',
                          AppTextStyles.bodySmall,
                          children: [
                            TextSpan(
                              text: '${isCredit ? 'Credit: ' : 'Debit: '} ${CurrencyFormatter.format(rod.toY)}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: rod.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Segment control to switch between Week / Month / Year
  Widget _buildPeriodSelector() {
    final periods = [AppStrings.week, AppStrings.month, AppStrings.year];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Three cards: Total In, Total Out, Net
  Widget _buildSummaryRow(double totalIn, double totalOut) {
    final net = totalIn - totalOut;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Credit',
            amount: totalIn,
            color: AppColors.credit,
            emoji: '📈',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: 'Debit',
            amount: totalOut,
            color: AppColors.debit,
            emoji: '📉',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: 'Net',
            amount: net,
            color: net >= 0 ? AppColors.credit : AppColors.debit,
            emoji: net >= 0 ? '✅' : '⚠️',
          ),
        ),
      ],
    );
  }

  /// Bank balances list
  Widget _buildBankBalances() {
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, state) {
        if (state is! BankLoaded || state.banks.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Balances', style: AppTextStyles.headingMedium),
            const SizedBox(height: 12),
            ...state.banks.map((bank) {
              // Calculate percentage of total net worth
              final pct = state.totalNetWorth > 0
                  ? bank.currentBalance / state.totalNetWorth
                  : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(bank.name, style: AppTextStyles.bodyLarge),
                        const Spacer(),
                        Text(
                          CurrencyFormatter.format(bank.currentBalance),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar showing share of total wealth
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct.clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        color: AppColors.accent,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  /// Dynamic overview bar chart based on selected period
  Widget _buildPeriodOverviewChart(List<TransactionModel> allTransactions) {
    final now = DateTime.now();
    final barGroups = <BarChartGroupData>[];
    double maxAmount = 0.0;
    
    // Determine the periods based on _selectedPeriod
    final int count = _selectedPeriod == AppStrings.week ? 7 : _selectedPeriod == AppStrings.year ? 5 : 6;
    
    // We will generate the periods in chronological order (oldest first)
    final periods = List.generate(count, (i) {
      final index = count - 1 - i; // reverse index so i=0 is oldest
      if (_selectedPeriod == AppStrings.week) {
        // Drop the time portion so that differences are exact days
        final startOfToday = DateTime(now.year, now.month, now.day);
        return startOfToday.subtract(Duration(days: index));
      } else if (_selectedPeriod == AppStrings.year) {
        return DateTime(now.year - index, 1, 1);
      } else { // Month
        int m = now.month - index;
        int y = now.year;
        while (m <= 0) {
          m += 12;
          y -= 1;
        }
        return DateTime(y, m, 1);
      }
    });

    for (int i = 0; i < periods.length; i++) {
      final period = periods[i];
      double credit = 0;
      double debit = 0;

      for (final t in allTransactions) {
        bool matches = false;
        if (_selectedPeriod == AppStrings.week) {
          matches = t.date.year == period.year && t.date.month == period.month && t.date.day == period.day;
        } else if (_selectedPeriod == AppStrings.year) {
          matches = t.date.year == period.year;
        } else { // Month
          matches = t.date.year == period.year && t.date.month == period.month;
        }

        if (matches) {
          if (t.type == TransactionType.credit) credit += t.amount;
          if (t.type == TransactionType.debit) debit += t.amount;
        }
      }

      if (credit > maxAmount) maxAmount = credit;
      if (debit > maxAmount) maxAmount = debit;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: credit,
              color: AppColors.credit,
              width: 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: debit,
              color: AppColors.debit,
              width: 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    final maxY = maxAmount == 0 ? 100.0 : maxAmount * 1.2;
    
    final title = _selectedPeriod == AppStrings.week ? 'Weekly Overview' : _selectedPeriod == AppStrings.year ? 'Yearly Overview' : 'Monthly Overview';
    final subtitle = _selectedPeriod == AppStrings.week ? 'Last 7 Days' : _selectedPeriod == AppStrings.year ? 'Last 5 Years' : 'Last 6 Months';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headingMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
              Row(
                children: [
                  _buildLegendItem(AppColors.credit, 'Credit'),
                  const SizedBox(width: 12),
                  _buildLegendItem(AppColors.debit, 'Debit'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final i = val.toInt();
                        if (i < 0 || i >= periods.length) return const SizedBox();
                        final p = periods[i];
                        
                        String text = '';
                        bool isCurrent = false;
                        if (_selectedPeriod == AppStrings.week) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          text = days[p.weekday - 1];
                          isCurrent = (p.year == now.year && p.month == now.month && p.day == now.day);
                        } else if (_selectedPeriod == AppStrings.year) {
                          text = p.year.toString();
                          isCurrent = p.year == now.year;
                        } else {
                          const monthNames = [
                            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                          ];
                          text = monthNames[p.month - 1];
                          isCurrent = (p.year == now.year && p.month == now.month);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            text,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                              color: isCurrent ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.surfaceLight,
                    getTooltipItem: (group, _, rod, __) {
                      final isCredit = rod.color == AppColors.credit;
                      return BarTooltipItem(
                        '${isCredit ? 'Credit' : 'Debit'}\n',
                        AppTextStyles.bodySmall,
                        children: [
                          TextSpan(
                            text: CurrencyFormatter.format(rod.toY),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: rod.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  /// Flow by category bar chart (Credit vs Debit)
  Widget _buildCategoryChart(List<TransactionModel> transactions) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) return const SizedBox();

        // Only look at transactions with a category
        final categoryTxns = transactions
            .where((t) => t.categoryId != null && t.type != TransactionType.transfer)
            .toList();

        if (categoryTxns.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Text('📊', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 12),
                Text(
                  'No categorized data yet.\nAdd transactions to see your chart!',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Aggregate credit and debit by category
        final Map<String, double> categoryCredit = {};
        final Map<String, double> categoryDebit = {};
        for (final txn in categoryTxns) {
          final key = txn.categoryId!;
          if (txn.type == TransactionType.credit) {
            categoryCredit[key] = (categoryCredit[key] ?? 0) + txn.amount;
          } else if (txn.type == TransactionType.debit) {
            categoryDebit[key] = (categoryDebit[key] ?? 0) + txn.amount;
          }
        }

        // Sort by total volume descending, take top 6
        final allCategoryIds = {...categoryCredit.keys, ...categoryDebit.keys}.toList();
        allCategoryIds.sort((a, b) {
          final volA = (categoryCredit[a] ?? 0) + (categoryDebit[a] ?? 0);
          final volB = (categoryCredit[b] ?? 0) + (categoryDebit[b] ?? 0);
          return volB.compareTo(volA);
        });
        final top = allCategoryIds.take(6).toList();

        // Build bar groups for fl_chart
        final barGroups = top.asMap().entries.map((e) {
          final catId = e.value;
          final credit = categoryCredit[catId] ?? 0;
          final debit = categoryDebit[catId] ?? 0;

          return BarChartGroupData(
            x: e.key,
            barRods: [
              if (credit > 0)
                BarChartRodData(
                  toY: credit,
                  color: AppColors.credit,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              if (debit > 0)
                BarChartRodData(
                  toY: debit,
                  color: AppColors.debit,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
            ],
          );
        }).toList();

        double maxAmount = 0.0;
        for (final catId in top) {
          final credit = categoryCredit[catId] ?? 0;
          final debit = categoryDebit[catId] ?? 0;
          if (credit > maxAmount) maxAmount = credit;
          if (debit > maxAmount) maxAmount = debit;
        }
        final maxY = maxAmount == 0 ? 100.0 : maxAmount * 1.2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Flow by Category', style: AppTextStyles.headingMedium),
            const SizedBox(height: 16),
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    // Bottom titles — category emoji
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final i = val.toInt();
                          if (i >= top.length) return const SizedBox();
                          final catId = top[i];
                          final cat = state.categories
                              .where((c) => c.id == catId)
                              .firstOrNull;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              cat?.emoji ?? '📦',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        },
                      ),
                    ),
                    // Left titles — amounts (hidden to keep it clean)
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  // Tap on a bar to see amount
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppColors.surfaceLight,
                      getTooltipItem: (group, _, rod, __) {
                        final catId = top[group.x];
                        final cat = state.categories
                            .where((c) => c.id == catId)
                            .firstOrNull;
                        final isCredit = rod.color == AppColors.credit;
                        return BarTooltipItem(
                          '${cat?.name ?? 'Other'}\n',
                          AppTextStyles.bodySmall,
                          children: [
                            TextSpan(
                              text: '${isCredit ? 'Credit: ' : 'Debit: '} ${CurrencyFormatter.format(rod.toY)}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: rod.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // ----- Legend -----
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: top.map((catId) {
                final cat = state.categories
                    .where((c) => c.id == catId)
                    .firstOrNull;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: cat?.color ?? AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${cat?.emoji ?? '📦'} ${cat?.name ?? 'Other'}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  /// Filter transactions based on selected period
  List<TransactionModel> _filterByPeriod(List<TransactionModel> all) {
    final now = DateTime.now();
    DateTime from;

    switch (_selectedPeriod) {
      case 'Week':
        from = now.subtract(const Duration(days: 7));
        break;
      case 'Year':
        from = DateTime(now.year, 1, 1);
        break;
      default: // Month
        from = DateTime(now.year, now.month, 1);
    }

    return all.where((t) => t.date.isAfter(from)).toList();
  }
}

/// A single summary card for Total In / Total Out / Net
class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String emoji;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label, style: AppTextStyles.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTextStyles.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
