// ============================================================
// contact_repository.dart
// Handles all contact database operations.
//
// SQLite table: contacts
//   id, name
// ============================================================

import '../../core/storage/database_service.dart';
import '../models/contact_model.dart';

class ContactRepository {
  final DatabaseService _db;

  ContactRepository(this._db);

  // ── Read ─────────────────────────────────────────────────
  /// Returns all contacts, sorted A-Z by name.
  Future<List<ContactModel>> loadContacts() async {
    final rows = await _db.getAll('contacts', orderBy: 'name ASC');
    return rows.map(ContactModel.fromMap).toList();
  }

  // ── Write ─────────────────────────────────────────────────
  /// Adds a new contact.
  Future<void> addContact(ContactModel contact) async {
    await _db.insert('contacts', contact.toMap());
  }

  /// Permanently deletes a contact.
  Future<void> deleteContact(String id) async {
    await _db.delete('contacts', id: id);
  }
}
