// ============================================================
// db_platform.dart — Conditional Platform Export
//
// This file is the KEY to cross-platform SQLite support.
//
// How Dart conditional exports work:
//   - If dart.library.html is available → we're on the WEB
//     → export db_platform_web.dart (uses WASM SQLite)
//   - Otherwise → we're on NATIVE (Android, iOS, Windows, macOS, Linux)
//     → export db_platform_native.dart (uses native SQLite)
//
// Any file that imports 'db_platform.dart' automatically gets
// the right implementation without any if/else code.
//
// Dart compiles ONLY the chosen export — the other file is
// completely excluded from the web build tree. This is why
// dart:io (which only exists on native) is safe in db_platform_native.dart.
// ============================================================

export 'db_platform_native.dart' if (dart.library.html) 'db_platform_web.dart';
