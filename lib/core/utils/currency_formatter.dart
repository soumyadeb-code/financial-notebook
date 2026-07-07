// ============================================================
// currency_formatter.dart
// Helper functions to format numbers as Indian Rupees.
// Example: 1234567.89 → ₹12,34,567.89
// ============================================================

import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  // Indian number format: 12,34,567 (not 1,234,567)
  static final _formatter = NumberFormat('#,##,##0.00', 'en_IN');

  /// Formats a double as an Indian Rupee string
  /// Example: format(1234.5) → '₹1,234.50'
  static String format(double amount) {
    return '₹${_formatter.format(amount)}';
  }

  /// Formats without the ₹ symbol
  /// Example: formatRaw(1234.5) → '1,234.50'
  static String formatRaw(double amount) {
    return _formatter.format(amount);
  }

  /// Parses a formatted string back to double
  /// Example: parse('1,234.50') → 1234.50
  static double parse(String text) {
    // Remove commas, spaces, and ₹ symbol before parsing
    final cleaned = text.replaceAll(',', '').replaceAll('₹', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}
