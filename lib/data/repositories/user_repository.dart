// ============================================================
// user_repository.dart
// Handles reading/writing the single user record in SQLite.
//
// The 'user' table has exactly ONE row (id = 1) representing
// the app owner. We upsert (insert-or-replace) to keep it simple.
// ============================================================

import 'dart:convert'; // For utf8 encoding (PIN hashing)

import 'package:crypto/crypto.dart'; // SHA-256 hashing

import '../../core/storage/database_service.dart';
import '../models/user_model.dart';

class UserRepository {
  final DatabaseService _db;

  // The ID we always use for the single user row
  static const int _userId = 1;

  UserRepository(this._db);

  // ── Read ─────────────────────────────────────────────────
  /// Loads the user record from SQLite.
  /// Returns null if no user has been set up yet (first launch).
  Future<UserModel?> loadUser() async {
    final rows = await _db.getWhere(
      'user',
      where: 'id = ?',
      whereArgs: [_userId],
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  // ── Write ─────────────────────────────────────────────────
  /// Saves the user's display name.
  /// Called during onboarding (first launch).
  Future<void> saveName(String name) async {
    await _db.insert('user', {
      'id': _userId,
      'name': name,
      'pin_hash': '',
      'biometric_enabled': 0,
      'categories_seeded': 0,
    });
  }

  /// Updates the user's display name (from Settings).
  Future<void> updateName(String name) async {
    await _db.updateWhere(
      'user',
      {'name': name},
      where: 'id = ?',
      whereArgs: [_userId],
    );
  }

  /// Hashes the PIN with SHA-256 and saves it.
  /// We NEVER store the raw PIN — only its hash.
  Future<void> savePin(String rawPin) async {
    final hash = _hashPin(rawPin);
    await _db.updateWhere(
      'user',
      {'pin_hash': hash},
      where: 'id = ?',
      whereArgs: [_userId],
    );
  }

  /// Returns true if rawPin matches the stored hash.
  Future<bool> verifyPin(String rawPin, String storedHash) async {
    return _hashPin(rawPin) == storedHash;
  }

  /// Updates PIN — first verifies the old one, then saves new one.
  Future<bool> updatePin(String oldRawPin, String newRawPin) async {
    final user = await loadUser();
    if (user == null) return false;
    if (!await verifyPin(oldRawPin, user.pinHash)) return false;
    await savePin(newRawPin);
    return true;
  }

  /// Saves whether biometric login is enabled.
  Future<void> setBiometricEnabled(bool enabled) async {
    await _db.updateWhere(
      'user',
      {'biometric_enabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [_userId],
    );
  }

  /// Marks that default categories have been seeded.
  /// So we don't re-seed them every time the app opens.
  Future<void> markCategoriesSeeded() async {
    await _db.updateWhere(
      'user',
      {'categories_seeded': 1},
      where: 'id = ?',
      whereArgs: [_userId],
    );
  }


  // ── Private Helpers ────────────────────────────────────────
  /// Converts rawPin → SHA-256 hex string.
  /// SHA-256 is a one-way hash — you can't reverse it to get the PIN back.
  String _hashPin(String rawPin) {
    final bytes = utf8.encode(rawPin);           // Convert string → bytes
    final digest = sha256.convert(bytes);        // Hash the bytes
    return digest.toString();                    // Return as hex string
  }
}
