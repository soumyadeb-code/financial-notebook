// ============================================================
// bank_repository.dart
// Handles all bank account database operations.
//
// SQLite table: banks
//   id, name, account_type, opening_balance,
//   current_balance, date_added, owner_name
// ============================================================

import '../../core/storage/database_service.dart';
import '../models/bank_model.dart';

class BankRepository {
  final DatabaseService _db;

  BankRepository(this._db);

  // ── Read ─────────────────────────────────────────────────
  /// Returns ALL bank accounts, sorted by date added (newest first).
  Future<List<BankModel>> loadBanks() async {
    final rows = await _db.getAll('banks', orderBy: 'date_added DESC');
    return rows.map(BankModel.fromMap).toList();
  }

  /// Returns a single bank by its ID, or null if not found.
  Future<BankModel?> getBankById(String id) async {
    final rows = await _db.getWhere(
      'banks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return BankModel.fromMap(rows.first);
  }

  /// Calculates the total net worth (sum of all current balances).
  Future<double> getTotalNetWorth() async {
    final result = await _db.rawQuery(
      'SELECT SUM(current_balance) AS total FROM banks',
    );
    // rawQuery returns a list; result[0]['total'] is the sum, or null if no banks
    return (result.first['total'] as double?) ?? 0.0;
  }

  // ── Write ─────────────────────────────────────────────────
  /// Inserts a new bank account into the database.
  Future<void> addBank(BankModel bank) async {
    await _db.insert('banks', bank.toMap());
  }

  /// Updates just the current_balance of a bank.
  /// Called automatically by TransactionRepository when a txn is added/deleted.
  Future<void> updateBalance(String bankId, double newBalance) async {
    await _db.updateWhere(
      'banks',
      {'current_balance': newBalance},
      where: 'id = ?',
      whereArgs: [bankId],
    );
  }

  /// Permanently deletes a bank account.
  /// Note: its transactions remain in the transactions table.
  Future<void> deleteBank(String id) async {
    await _db.delete('banks', id: id);
  }
}
