// ============================================================
// user_bloc.dart — corrected to use actual event/state field names
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;

  UserBloc(this._repository) : super(const UserLoading()) {
    on<LoadUser>(_onLoad);
    on<SaveName>(_onSaveName);
    on<SavePin>(_onSavePin);
    on<VerifyPin>(_onVerifyPin);
    on<UpdateName>(_onUpdateName);
    on<UpdatePin>(_onUpdatePin);
  }

  /// On app launch: load user from SQLite and route to correct screen.
  Future<void> _onLoad(LoadUser event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    final user = await _repository.loadUser();

    if (user == null) {
      emit(const UserNotSetup());
    } else if (user.pinHash.isEmpty) {
      emit(UserNeedsPinSetup(user.name));
    } else {
      emit(UserNeedsPinVerification(user.name));
    }
  }

  /// Onboarding step 1: save display name.
  Future<void> _onSaveName(SaveName event, Emitter<UserState> emit) async {
    await _repository.saveName(event.name);
    emit(UserNeedsPinSetup(event.name));
  }

  /// Onboarding step 2: hash and save PIN, then authenticate.
  Future<void> _onSavePin(SavePin event, Emitter<UserState> emit) async {
    await _repository.savePin(event.pin);
    final user = await _repository.loadUser();
    if (user != null) {
      emit(UserAuthenticated(user.name));
    }
  }

  /// Login: verify typed PIN against stored SHA-256 hash.
  Future<void> _onVerifyPin(VerifyPin event, Emitter<UserState> emit) async {
    final user = await _repository.loadUser();
    if (user == null) {
      emit(const PinVerificationFailed('User not found'));
      return;
    }
    final isCorrect = await _repository.verifyPin(event.pin, user.pinHash);
    if (isCorrect) {
      emit(UserAuthenticated(user.name));
    } else {
      emit(const PinVerificationFailed('Incorrect PIN. Try again.'));
    }
  }

  Future<void> _onUpdateName(UpdateName event, Emitter<UserState> emit) async {
    await _repository.updateName(event.name);
    final user = await _repository.loadUser();
    if (user != null) {
      emit(UserAuthenticated(user.name));
    }
  }

  /// Settings: change PIN (verifies old PIN first).
  Future<void> _onUpdatePin(UpdatePin event, Emitter<UserState> emit) async {
    final success = await _repository.updatePin(event.oldPin, event.newPin);
    if (!success) {
      emit(const PinVerificationFailed('Current PIN is incorrect'));
    }
  }
}
