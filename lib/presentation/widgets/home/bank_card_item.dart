// ============================================================
// bank_card_item.dart
// A single bank account card shown in the "My Accounts" list.
// Shows the bank name, type, owner, balance, and date.
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/bank_model.dart';

class BankCardItem extends StatelessWidget {
  final BankModel bank;
  final VoidCallback? onDelete; // Called when trash icon is tapped

  const BankCardItem({
    super.key,
    required this.bank,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getAccountColor(bank.accountType).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ----- Bank Icon -----
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getAccountColor(bank.accountType).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getAccountIcon(bank.accountType),
              color: _getAccountColor(bank.accountType),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // ----- Bank Details -----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank.name, style: AppTextStyles.headingSmall),
                const SizedBox(height: 2),
                Row(
                  children: [
                    // Account type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getAccountColor(bank.accountType).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        bank.accountType.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getAccountColor(bank.accountType),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bank.ownerName,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ----- Balance + Date + Delete -----
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(bank.currentBalance),
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormatter.toDisplay(bank.dateAdded),
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 4),
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
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns a color based on account type
  Color _getAccountColor(String type) {
    switch (type.toLowerCase()) {
      case 'savings':
        return AppColors.accent;
      case 'salary':
        return AppColors.credit;
      case 'current':
        return const Color(0xFF3B82F6);
      case 'credit card':
        return AppColors.debit;
      case 'wallet':
        return AppColors.transfer;
      default:
        return AppColors.accent;
    }
  }

  /// Returns an icon based on account type
  IconData _getAccountIcon(String type) {
    switch (type.toLowerCase()) {
      case 'savings':
        return Icons.account_balance;
      case 'salary':
        return Icons.work_outline;
      case 'current':
        return Icons.business;
      case 'credit card':
        return Icons.credit_card;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.account_balance;
    }
  }
}
