// ============================================================
// user_state.dart
// Defines all possible states the UserBloc can be in.
// The UI watches these states and rebuilds accordingly.
// ============================================================

import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

/// Initial state — we haven't loaded user data yet
class UserInitial extends UserState {
  const UserInitial();
}

/// Loading state — waiting for storage to respond
class UserLoading extends UserState {
  const UserLoading();
}

/// The app is not set up — user needs to enter their name
class UserNotSetup extends UserState {
  const UserNotSetup();
}

/// User has a name but no PIN — needs to set up PIN
class UserNeedsPinSetup extends UserState {
  final String name;
  const UserNeedsPinSetup(this.name);

  @override
  List<Object?> get props => [name];
}

/// User is set up but needs to verify their PIN
class UserNeedsPinVerification extends UserState {
  final String name;
  final bool biometricEnabled;
  const UserNeedsPinVerification(this.name, {this.biometricEnabled = false});

  @override
  List<Object?> get props => [name, biometricEnabled];
}

/// User has been successfully authenticated — enter the app
class UserAuthenticated extends UserState {
  final String name;
  final bool biometricEnabled;
  const UserAuthenticated(this.name, {this.biometricEnabled = false});

  @override
  List<Object?> get props => [name, biometricEnabled];
}

/// PIN was wrong — show an error
class PinVerificationFailed extends UserState {
  final String message;
  const PinVerificationFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Something went wrong
class UserError extends UserState {
  final String message;
  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
