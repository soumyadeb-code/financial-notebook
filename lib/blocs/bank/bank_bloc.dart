// ============================================================
// bank_bloc.dart — corrected to use actual event/state field names
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/bank_repository.dart';
import 'bank_event.dart';
import 'bank_state.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
  final BankRepository _repository;

  BankBloc(this._repository) : super(const BankLoading()) {
    on<LoadBanks>(_onLoad);
    on<AddBank>(_onAdd);
    on<DeleteBank>(_onDelete);
    on<RefreshBanks>(_onRefresh);
  }

  Future<void> _onLoad(LoadBanks event, Emitter<BankState> emit) async {
    emit(const BankLoading());
    final banks = await _repository.loadBanks();
    // BankLoaded(this.banks) — positional constructor, totalNetWorth is a getter
    emit(BankLoaded(banks));
  }

  Future<void> _onAdd(AddBank event, Emitter<BankState> emit) async {
    await _repository.addBank(event.bank);
    final banks = await _repository.loadBanks();
    emit(BankLoaded(banks));
  }

  Future<void> _onDelete(DeleteBank event, Emitter<BankState> emit) async {
    // event.bankId is the field name (not event.id)
    await _repository.deleteBank(event.bankId);
    final banks = await _repository.loadBanks();
    emit(BankLoaded(banks));
  }

  Future<void> _onRefresh(RefreshBanks event, Emitter<BankState> emit) async {
    final banks = await _repository.loadBanks();
    emit(BankLoaded(banks));
  }
}
