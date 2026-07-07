// ============================================================
// bank_event.dart + bank_state.dart
// Events and States for the BankBloc.
// ============================================================

import 'package:equatable/equatable.dart';
import '../../data/models/bank_model.dart';

// ===== EVENTS =====
abstract class BankEvent extends Equatable {
  const BankEvent();
  @override
  List<Object?> get props => [];
}

/// Load all banks from storage
class LoadBanks extends BankEvent {
  const LoadBanks();
}

/// Add a new bank account
class AddBank extends BankEvent {
  final BankModel bank;
  const AddBank(this.bank);

  @override
  List<Object?> get props => [bank];
}

/// Delete a bank account by ID
class DeleteBank extends BankEvent {
  final String bankId;
  const DeleteBank(this.bankId);

  @override
  List<Object?> get props => [bankId];
}

/// Reload banks (called after transactions update balances)
class RefreshBanks extends BankEvent {
  const RefreshBanks();
}
