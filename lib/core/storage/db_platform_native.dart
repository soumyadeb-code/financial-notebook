// ============================================================
// db_platform_native.dart — Native SQLite Implementation
// Used on: Android, iOS, Windows, macOS, Linux
//
// On Android/iOS:  sqflite uses platform channels (built-in)
// On Desktop:      sqflite_common_ffi loads native sqlite3 library
//
// NOTE: This file uses dart:io (Platform.isWindows etc.) and
// dart:ffi (via sqflite_common_ffi). Both are ONLY available on
// native — this file is NEVER compiled for web, so it is safe.
// ============================================================

import 'dart:io'; // Safe: this file is excluded from web builds by db_platform.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Desktop FFI — re-exports sqflite_common

// Re-export all shared SQLite types (Database, DatabaseExecutor, etc.)
// database_service.dart gets these types through db_platform.dart → this file
export 'package:sqflite_common/sqlite_api.dart';

/// Returns the correct DatabaseFactory for this native platform.
///
/// Desktop (Windows/macOS/Linux) → sqflite_common_ffi's native sqlite3 factory
/// Mobile  (Android/iOS)         → sqflite's default platform-channel factory
DatabaseFactory get sqliteDatabaseFactory {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return databaseFactoryFfi; // Uses system sqlite3 (.dll / .so / .dylib)
  }
  // On Android/iOS the global databaseFactory is pre-set by the sqflite plugin
  return databaseFactory;
}

/// One-time setup called from DatabaseService.init() before opening any DB.
Future<void> initializeDatabaseFactory() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Load the native sqlite3 library and register the FFI factory
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Mobile: no-op — sqflite's platform channel factory is already active
}
