// ============================================================
// user_event.dart
// Defines all the "commands" that can be sent to the UserBloc.
// Think of events as user actions (e.g., "save my name", "verify PIN").
// ============================================================

import 'package:equatable/equatable.dart';

// All events extend Equatable so Flutter can compare them efficiently
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered on app start — loads user data from storage
class LoadUser extends UserEvent {
  const LoadUser();
}

/// Triggered when the user types their name and taps Continue
class SaveName extends UserEvent {
  final String name;
  const SaveName(this.name);

  @override
  List<Object?> get props => [name];
}

/// Triggered when the user sets their 6-digit PIN
class SavePin extends UserEvent {
  final String pin; // Plain PIN — will be hashed in the repository
  const SavePin(this.pin);

  @override
  List<Object?> get props => [pin];
}

/// Triggered when the user enters their PIN to log in
class VerifyPin extends UserEvent {
  final String pin; // Plain PIN entered by the user
  const VerifyPin(this.pin);

  @override
  List<Object?> get props => [pin];
}


/// Triggered when the user updates their name in Settings
class UpdateName extends UserEvent {
  final String name;
  const UpdateName(this.name);

  @override
  List<Object?> get props => [name];
}

/// Triggered when the user changes their PIN in Settings
class UpdatePin extends UserEvent {
  final String oldPin;
  final String newPin;
  const UpdatePin({required this.oldPin, required this.newPin});

  @override
  List<Object?> get props => [oldPin, newPin];
}
