// ============================================================
// transaction_bloc.dart
// Manages all transaction operations.
// TransactionRepository handles balance updates internally.
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;

  TransactionBloc(this._repository) : super(const TransactionLoading()) {
    on<LoadTransactions>(_onLoad);
    on<AddTransaction>(_onAdd);
    on<DeleteTransaction>(_onDelete);
  }

  Future<void> _onLoad(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(const TransactionLoading());
    final transactions = await _repository.loadTransactions();
    final totalCredit = await _repository.getTotalCredit();
    final totalDebit = await _repository.getTotalDebit();
    emit(TransactionLoaded(
      transactions,
      totalCredit: totalCredit,
      totalDebit: totalDebit,
    ));
  }

  /// Add transaction — the repo also updates bank balances atomically.
  Future<void> _onAdd(
      AddTransaction event, Emitter<TransactionState> emit) async {
    final transactions = await _repository.addTransaction(event.transaction);
    final totalCredit = await _repository.getTotalCredit();
    final totalDebit = await _repository.getTotalDebit();
    emit(TransactionLoaded(
      transactions,
      totalCredit: totalCredit,
      totalDebit: totalDebit,
    ));
  }

  /// Delete transaction — the repo reverses the bank balance change.
  Future<void> _onDelete(
      DeleteTransaction event, Emitter<TransactionState> emit) async {
    final transactions =
        await _repository.deleteTransaction(event.transaction);
    final totalCredit = await _repository.getTotalCredit();
    final totalDebit = await _repository.getTotalDebit();
    emit(TransactionLoaded(
      transactions,
      totalCredit: totalCredit,
      totalDebit: totalDebit,
    ));
  }
}
