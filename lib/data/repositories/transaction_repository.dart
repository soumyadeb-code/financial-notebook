// ============================================================
// transaction_repository.dart
// Handles all transaction database operations.
//
// CRITICAL: Every time a transaction is added or deleted,
// this repository also updates the bank's current_balance.
// Both operations happen inside a single SQL TRANSACTION
// so they either BOTH succeed or BOTH fail (atomic).
//
// SQLite table: transactions
//   id, bank_id, type, amount, contact_id, category_id,
//   note, date, transfer_to_bank_id
// ============================================================

// sqflite_common is pure Dart (no dart:io, no dart:ffi) — works on web too
import 'package:sqflite_common/sqlite_api.dart';

import '../../core/storage/database_service.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final DatabaseService _db;

  TransactionRepository(this._db);

  // ── Read ─────────────────────────────────────────────────
  /// Returns all transactions, sorted by date descending (newest first).
  Future<List<TransactionModel>> loadTransactions() async {
    final rows = await _db.getAll(
      'transactions',
      orderBy: 'date DESC',
    );
    return rows.map(TransactionModel.fromMap).toList();
  }

  /// Returns total credit amount for all transactions.
  Future<double> getTotalCredit() async {
    final result = await _db.rawQuery(
      "SELECT SUM(amount) AS total FROM transactions WHERE type = 'credit'",
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  /// Returns total debit amount for all transactions.
  Future<double> getTotalDebit() async {
    final result = await _db.rawQuery(
      "SELECT SUM(amount) AS total FROM transactions WHERE type = 'debit'",
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  // ── Write ─────────────────────────────────────────────────
  /// Adds a transaction AND updates the bank balance atomically.
  ///
  /// Credit → bank balance goes UP
  /// Debit  → bank balance goes DOWN
  /// Transfer → FROM bank goes DOWN, TO bank goes UP
  Future<List<TransactionModel>> addTransaction(
      TransactionModel txn) async {
    await _db.runInTransaction((txnDb) async {
      // 1️⃣ Insert the transaction row
      await txnDb.insert(
        'transactions',
        txn.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2️⃣ Adjust the FROM bank's balance
      final fromBank = await _getBankInTxn(txnDb, txn.bankId);
      if (fromBank != null) {
        final double newBalance;
        if (txn.type == TransactionType.credit) {
          newBalance = fromBank.currentBalance + txn.amount;
        } else {
          // debit or transfer: money leaves this account
          newBalance = fromBank.currentBalance - txn.amount;
        }
        await _updateBalanceInTxn(txnDb, txn.bankId, newBalance);
      }

      // 3️⃣ If transfer: also adjust the TO bank's balance
      if (txn.type == TransactionType.transfer &&
          txn.transferToBankId != null) {
        final toBank = await _getBankInTxn(txnDb, txn.transferToBankId!);
        if (toBank != null) {
          await _updateBalanceInTxn(
            txnDb,
            txn.transferToBankId!,
            toBank.currentBalance + txn.amount, // TO bank goes UP
          );
        }
      }
    });

    // Return the updated list after the transaction
    return loadTransactions();
  }

  /// Deletes a transaction AND REVERSES the bank balance change.
  ///
  /// This means deleting a credit will REDUCE the balance,
  /// and deleting a debit will INCREASE it (as if it never happened).
  Future<List<TransactionModel>> deleteTransaction(
      TransactionModel txn) async {
    await _db.runInTransaction((txnDb) async {
      // 1️⃣ Delete the transaction row
      await txnDb.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [txn.id],
      );

      // 2️⃣ Reverse the FROM bank's balance
      final fromBank = await _getBankInTxn(txnDb, txn.bankId);
      if (fromBank != null) {
        final double restoredBalance;
        if (txn.type == TransactionType.credit) {
          // Undo a credit: balance goes DOWN
          restoredBalance = fromBank.currentBalance - txn.amount;
        } else {
          // Undo a debit or transfer: balance goes UP
          restoredBalance = fromBank.currentBalance + txn.amount;
        }
        await _updateBalanceInTxn(txnDb, txn.bankId, restoredBalance);
      }

      // 3️⃣ If transfer: also reverse the TO bank
      if (txn.type == TransactionType.transfer &&
          txn.transferToBankId != null) {
        final toBank = await _getBankInTxn(txnDb, txn.transferToBankId!);
        if (toBank != null) {
          await _updateBalanceInTxn(
            txnDb,
            txn.transferToBankId!,
            toBank.currentBalance - txn.amount, // Undo the credit
          );
        }
      }
    });

    return loadTransactions();
  }

  // ── Private Helpers (run inside SQL transactions) ──────────
  /// Fetches a BankModel inside an existing database transaction.
  Future<BankModel?> _getBankInTxn(DatabaseExecutor txnDb, String bankId) async {
    final rows = await txnDb.query(
      'banks',
      where: 'id = ?',
      whereArgs: [bankId],
    );
    if (rows.isEmpty) return null;
    return BankModel.fromMap(rows.first);
  }

  /// Updates a bank balance inside an existing database transaction.
  Future<void> _updateBalanceInTxn(
    DatabaseExecutor txnDb,
    String bankId,
    double newBalance,
  ) async {
    await txnDb.update(
      'banks',
      {'current_balance': newBalance},
      where: 'id = ?',
      whereArgs: [bankId],
    );
  }
}
