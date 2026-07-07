// ============================================================
// date_formatter.dart
// Helper functions to format dates in a human-readable way.
// ============================================================

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  // Standard format: 06 Jul 2026
  static final _displayFormat = DateFormat('dd MMM yyyy');

  // Short format: 06 Jul
  static final _shortFormat = DateFormat('dd MMM');

  // For storage (ISO format): 2026-07-06
  static final _storageFormat = DateFormat('yyyy-MM-dd');

  /// Formats a DateTime as '06 Jul 2026'
  static String toDisplay(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Formats a DateTime as '06 Jul' (no year)
  static String toShort(DateTime date) {
    return _shortFormat.format(date);
  }

  /// Formats a DateTime for storage as '2026-07-06'
  static String toStorage(DateTime date) {
    return _storageFormat.format(date);
  }

  /// Parses a storage date string back to DateTime
  static DateTime fromStorage(String dateStr) {
    return _storageFormat.parse(dateStr);
  }

  /// Returns a relative label like 'Today', 'Yesterday', or the date
  static String toRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return toDisplay(date);
  }
}
