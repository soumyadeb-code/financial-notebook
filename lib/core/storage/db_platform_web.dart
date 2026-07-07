// ============================================================
// db_platform_web.dart — Web SQLite Implementation
// Used on: Flutter Web (Chrome, Firefox, Safari, Edge)
//
// How web SQLite works:
//   1. sqlite3 compiled to WebAssembly (WASM) — near-native speed
//   2. Data persists via IndexedDB — survives page refreshes
//   3. sqflite_common_ffi_web wires this into the sqflite API
//
// No dart:io or dart:ffi here — 100% web-safe.
// ============================================================

// sqlite_api.dart: DatabaseFactory class + Database, DatabaseExecutor, etc.
import 'package:sqflite_common/sqlite_api.dart';
// sqflite.dart: exports databaseFactory (the global settable getter/setter)
import 'package:sqflite_common/sqflite.dart' show databaseFactory;
// sqflite_common_ffi_web: provides databaseFactoryFfiWeb (WASM factory)
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Re-export shared SQLite types so database_service.dart gets them
// by importing db_platform.dart (which conditionally exports this file on web)
export 'package:sqflite_common/sqlite_api.dart';

/// Returns the web DatabaseFactory (WASM SQLite + IndexedDB backend).
DatabaseFactory get sqliteDatabaseFactory => databaseFactoryFfiWeb;

/// Sets the global databaseFactory to the web WASM implementation.
/// Must be called once at startup (from DatabaseService.init()).
Future<void> initializeDatabaseFactory() async {
  // databaseFactory is the global from sqflite_common/sqflite.dart
  // Setting it routes all openDatabase() calls to the WASM implementation
  databaseFactory = databaseFactoryFfiWeb;
}
