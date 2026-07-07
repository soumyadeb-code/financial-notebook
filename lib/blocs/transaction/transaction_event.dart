// ============================================================
// transaction_event.dart
// ============================================================

import 'package:equatable/equatable.dart';
import '../../data/models/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;
  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final TransactionModel transaction;
  const DeleteTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
