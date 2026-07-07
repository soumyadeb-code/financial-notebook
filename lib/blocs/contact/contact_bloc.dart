// ============================================================
// contact_bloc.dart — corrected to use actual event field names
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/contact_repository.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRepository _repository;

  ContactBloc(this._repository) : super(const ContactLoading()) {
    on<LoadContacts>(_onLoad);
    on<AddContact>(_onAdd);
    on<DeleteContact>(_onDelete);
  }

  Future<void> _onLoad(LoadContacts event, Emitter<ContactState> emit) async {
    emit(const ContactLoading());
    final contacts = await _repository.loadContacts();
    emit(ContactLoaded(contacts));
  }

  Future<void> _onAdd(AddContact event, Emitter<ContactState> emit) async {
    await _repository.addContact(event.contact);
    final contacts = await _repository.loadContacts();
    emit(ContactLoaded(contacts));
  }

  Future<void> _onDelete(
      DeleteContact event, Emitter<ContactState> emit) async {
    // event.contactId is the field name (not event.id)
    await _repository.deleteContact(event.contactId);
    final contacts = await _repository.loadContacts();
    emit(ContactLoaded(contacts));
  }
}
