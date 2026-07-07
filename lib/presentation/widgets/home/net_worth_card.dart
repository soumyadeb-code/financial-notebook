// ============================================================
// net_worth_card.dart
// The big purple card at the top of the Home screen.
// Shows total balance with a hide/show toggle (eye icon).
// Also shows Total In (green) and Total Out (red).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/bank/bank_bloc.dart';
import '../../../blocs/bank/bank_state.dart';
import '../../../blocs/transaction/transaction_bloc.dart';
import '../../../blocs/transaction/transaction_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../common/gradient_card.dart';

class NetWorthCard extends StatefulWidget {
  const NetWorthCard({super.key});

  @override
  State<NetWorthCard> createState() => _NetWorthCardState();
}

class _NetWorthCardState extends State<NetWorthCard> {
  // Whether the balance is visible or masked with dots
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, bankState) {
        // Get net worth from bank balances
        double netWorth = 0;
        if (bankState is BankLoaded) {
          netWorth = bankState.totalNetWorth;
        }

        return BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, txnState) {
            // Get total in/out from transactions
            double totalIn = 0;
            double totalOut = 0;
            if (txnState is TransactionLoaded) {
              totalIn = txnState.totalCredit;
              totalOut = txnState.totalDebit;
            }

            return GradientCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----- Top Label -----
                  Text(
                    AppStrings.totalNetWorth,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ----- Big Balance + Eye Toggle -----
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _isBalanceVisible
                              ? CurrencyFormatter.format(netWorth)
                              : '₹ •••••••',
                          style: AppTextStyles.displayLarge,
                        ),
                      ),
                      // Eye icon button to show/hide balance
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isBalanceVisible = !_isBalanceVisible;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _isBalanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ----- Summary Row: Total In / Total Out -----
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            label: AppStrings.totalIn,
                            amount: totalIn,
                            isCredit: true,
                            isVisible: _isBalanceVisible,
                          ),
                        ),
                        Container(width: 1, height: 32, color: Colors.white24),
                        Expanded(
                          child: _SummaryItem(
                            label: AppStrings.totalOut,
                            amount: totalOut,
                            isCredit: false,
                            isVisible: _isBalanceVisible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Small widget for the Total In / Total Out items
class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final bool isCredit;
  final bool isVisible;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.isCredit,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCredit ? Icons.arrow_upward : Icons.arrow_downward,
              color: isCredit ? AppColors.credit : AppColors.debit,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isVisible ? CurrencyFormatter.format(amount) : '₹ •••',
          style: AppTextStyles.bodyLarge.copyWith(
            color: isCredit ? AppColors.credit : AppColors.debit,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
