// ============================================================
// contact_state.dart
// ============================================================

import 'package:equatable/equatable.dart';
import '../../data/models/contact_model.dart';

abstract class ContactState extends Equatable {
  const ContactState();
  @override
  List<Object?> get props => [];
}

class ContactLoading extends ContactState {
  const ContactLoading();
}

class ContactLoaded extends ContactState {
  final List<ContactModel> contacts;
  const ContactLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class ContactError extends ContactState {
  final String message;
  const ContactError(this.message);

  @override
  List<Object?> get props => [message];
}
