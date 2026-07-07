// ============================================================
// transaction_state.dart
// TransactionLoaded now takes pre-computed totals from SQLite
// (via SUM() queries), so they're accurate even if transactions
// are filtered or paginated in the future.
// ============================================================

import 'package:equatable/equatable.dart';
import '../../data/models/transaction_model.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;

  // These come directly from SQLite SUM() queries — more reliable
  // than computing from the local list (handles filtered views too)
  final double totalCredit;
  final double totalDebit;

  const TransactionLoaded(
    this.transactions, {
    this.totalCredit = 0.0,
    this.totalDebit = 0.0,
  });

  @override
  List<Object?> get props => [transactions, totalCredit, totalDebit];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
