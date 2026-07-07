// ============================================================
// database_service.dart — Cross-Platform SQLite Service
//
// This file is now 100% platform-agnostic. It has NO:
//   ❌ dart:io  (not available on web)
//   ❌ sqflite_common_ffi imports (not available on web)
//   ❌ Platform.isWindows / Platform.isLinux checks
//
// Instead, ALL platform differences are handled in:
//   ✅ db_platform_native.dart  — for Android, iOS, Windows, macOS, Linux
//   ✅ db_platform_web.dart     — for Flutter Web (WASM + IndexedDB)
//   ✅ db_platform.dart         — picks the right one at compile time
//
// Database Schema (5 tables):
//   📋 user        → name, PIN hash, biometric flag, seed flag
//   🏦 banks       → bank accounts with current balance
//   👤 contacts    → people you send/receive money to/from
//   🏷️  categories  → spending/earning categories (Food, Transport, etc.)
//   💳 transactions → all money movements (credit, debit, transfer)
// ============================================================

import 'package:path/path.dart' as p;

// This single import gives us everything we need:
//   - sqliteDatabaseFactory  → the right factory for current platform
//   - initializeDatabaseFactory() → one-time setup
//   - Database, DatabaseExecutor, ConflictAlgorithm, OpenDatabaseOptions, Batch
import 'db_platform.dart';

class DatabaseService {
  // The live database connection — opened once, reused forever
  Database? _db;

  // ── Public getter ─────────────────────────────────────────
  /// Returns the database (initializing it if needed).
  /// Lazily initialized with null-coalescing assignment (??=).
  Future<Database> get database async {
    _db ??= await _openDatabase();
    return _db!;
  }

  // ── Initialization ────────────────────────────────────────
  /// Call this ONCE from main.dart before starting the app.
  /// It performs platform setup and opens the database file.
  Future<void> init() async {
    // Step 1: Set up the correct SQLite factory for this platform.
    // On desktop → loads native sqlite3 library
    // On web     → sets up WASM SQLite factory
    // On mobile  → no-op (factory already correct)
    await initializeDatabaseFactory();

    // Step 2: Open (or create) the database file
    _db = await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    // Get the platform-appropriate path for storing the DB file:
    //   Android/iOS:        /data/app/.../databases/
    //   Windows/macOS/Linux: ~/Documents/expense_vault/  (or similar)
    //   Web:                 IndexedDB key namespace
    final dbPath = await sqliteDatabaseFactory.getDatabasesPath();
    final fullPath = p.join(dbPath, 'expense_vault.db');

    // openDatabase will:
    //   - Create the file (or IndexedDB namespace) if it doesn't exist
    //   - Call onCreate → _createTables on first launch (version 1)
    //   - Call onUpgrade if the version number increases in a future update
    return sqliteDatabaseFactory.openDatabase(
      fullPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createTables,
      ),
    );
  }

  // ── Table Creation ────────────────────────────────────────
  /// Called automatically on the FIRST app launch.
  /// Creates all 5 tables inside a batch for performance.
  Future<void> _createTables(Database db, int version) async {
    // A batch groups multiple SQL statements into one transaction:
    // all statements execute together, much faster than one-by-one.
    final batch = db.batch();

    // ── user table ──────────────────────────────────────────
    // Always one row (id = 1). Stores the logged-in user's info.
    batch.execute('''
      CREATE TABLE IF NOT EXISTS user (
        id                INTEGER PRIMARY KEY,
        name              TEXT    NOT NULL DEFAULT '',
        pin_hash          TEXT    NOT NULL DEFAULT '',
        biometric_enabled INTEGER NOT NULL DEFAULT 0,
        categories_seeded INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // ── banks table ─────────────────────────────────────────
    // Each row = one bank account (SBI Savings, HDFC Salary, etc.)
    batch.execute('''
      CREATE TABLE IF NOT EXISTS banks (
        id               TEXT PRIMARY KEY,
        name             TEXT NOT NULL,
        account_type     TEXT NOT NULL,
        opening_balance  REAL NOT NULL DEFAULT 0,
        current_balance  REAL NOT NULL DEFAULT 0,
        date_added       TEXT NOT NULL,
        owner_name       TEXT NOT NULL DEFAULT ''
      )
    ''');

    // ── contacts table ──────────────────────────────────────
    // Each row = one person you transact with
    batch.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        id   TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    // ── categories table ────────────────────────────────────
    // color is stored as an integer (ARGB value, e.g., 0xFFEF4444 for red)
    batch.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id    TEXT PRIMARY KEY,
        name  TEXT    NOT NULL,
        emoji TEXT    NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    // ── transactions table ──────────────────────────────────
    // type = 'credit', 'debit', or 'transfer'
    // date = ISO 8601 string: '2026-07-06T12:00:00.000Z'
    // Nullable columns: contact_id, category_id, note, transfer_to_bank_id
    batch.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id                   TEXT PRIMARY KEY,
        bank_id              TEXT NOT NULL,
        type                 TEXT NOT NULL,
        amount               REAL NOT NULL,
        contact_id           TEXT,
        category_id          TEXT,
        note                 TEXT,
        date                 TEXT NOT NULL,
        transfer_to_bank_id  TEXT
      )
    ''');

    // Commit all table creation at once
    await batch.commit(noResult: true);
  }

  // ── Generic CRUD Helpers ──────────────────────────────────
  // These simple helpers are called by repositories so they
  // don't need to write raw SQL everywhere.

  /// Insert (or replace) a row into [table].
  /// [values] is a Map of column name → value.
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace, // Upsert behaviour
    );
  }

  /// Read ALL rows from [table].
  /// [orderBy] is optional, e.g. 'date DESC'.
  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(table, orderBy: orderBy);
  }

  /// Read rows from [table] matching a [where] condition.
  /// Example: where: 'bank_id = ?', whereArgs: ['abc-123']
  Future<List<Map<String, dynamic>>> getWhere(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  /// Update columns in [table] for rows matching [where].
  Future<int> updateWhere(
    String table,
    Map<String, dynamic> values, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  /// Delete a single row by primary key [id].
  Future<int> delete(
    String table, {
    required String id,
    String idColumn = 'id',
  }) async {
    final db = await database;
    return db.delete(table, where: '$idColumn = ?', whereArgs: [id]);
  }

  /// Run a raw SQL query (for aggregations like SUM, COUNT, etc.)
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  /// Run multiple SQL operations atomically.
  /// If any operation fails, ALL are rolled back (nothing is saved).
  /// Used in TransactionRepository to update a transaction AND
  /// the bank balance in a single atomic operation.
  Future<void> runInTransaction(
      Future<void> Function(DatabaseExecutor txn) action) async {
    final db = await database;
    await db.transaction((txn) async {
      await action(txn);
    });
  }
}
