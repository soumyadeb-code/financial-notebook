// ============================================================
// bank_state.dart
// Possible states for the BankBloc.
// ============================================================

import 'package:equatable/equatable.dart';
import '../../data/models/bank_model.dart';

abstract class BankState extends Equatable {
  const BankState();
  @override
  List<Object?> get props => [];
}

/// Loading banks from storage
class BankLoading extends BankState {
  const BankLoading();
}

/// Banks loaded successfully
class BankLoaded extends BankState {
  final List<BankModel> banks;

  const BankLoaded(this.banks);

  /// Total net worth = sum of all bank balances
  double get totalNetWorth =>
      banks.fold(0.0, (sum, bank) => sum + bank.currentBalance);

  @override
  List<Object?> get props => [banks];
}

/// An error occurred
class BankError extends BankState {
  final String message;
  const BankError(this.message);

  @override
  List<Object?> get props => [message];
}
