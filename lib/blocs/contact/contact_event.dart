// ============================================================
// contact_event.dart
// ============================================================

import 'package:equatable/equatable.dart';
import '../../data/models/contact_model.dart';

abstract class ContactEvent extends Equatable {
  const ContactEvent();
  @override
  List<Object?> get props => [];
}

class LoadContacts extends ContactEvent {
  const LoadContacts();
}

class AddContact extends ContactEvent {
  final ContactModel contact;
  const AddContact(this.contact);

  @override
  List<Object?> get props => [contact];
}

class DeleteContact extends ContactEvent {
  final String contactId;
  const DeleteContact(this.contactId);

  @override
  List<Object?> get props => [contactId];
}
