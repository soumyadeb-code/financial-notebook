// ============================================================
// transaction_model.dart
// Represents a money movement event.
// Could be: credit (money in), debit (money out), or
//           transfer (between two of your own accounts).
// ============================================================

/// The three types of transactions
enum TransactionType {
  credit,   // Money coming INTO an account
  debit,    // Money going OUT of an account
  transfer, // Moving money from one account to another
}

class TransactionModel {
  final String id;                     // Unique ID
  final String bankId;                 // Which bank account this belongs to
  final TransactionType type;          // credit / debit / transfer
  final double amount;                 // How much money
  final String? contactId;             // Optional: who paid/received (from ContactModel)
  final String? categoryId;            // Optional: what category (from CategoryModel)
  final String? note;                  // Optional: user's note (e.g., "Rent payment")
  final DateTime date;                 // When this transaction happened
  final String? transferToBankId;      // Only for transfers: destination bank ID

  const TransactionModel({
    required this.id,
    required this.bankId,
    required this.type,
    required this.amount,
    this.contactId,
    this.categoryId,
    this.note,
    required this.date,
    this.transferToBankId,
  });

  // Convert enum to string for storage
  static String _typeToString(TransactionType type) {
    switch (type) {
      case TransactionType.credit:
        return 'credit';
      case TransactionType.debit:
        return 'debit';
      case TransactionType.transfer:
        return 'transfer';
    }
  }

  // Convert string back to enum
  static TransactionType _typeFromString(String str) {
    switch (str) {
      case 'credit':
        return TransactionType.credit;
      case 'debit':
        return TransactionType.debit;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.debit;
    }
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bank_id': bankId,
      'type': _typeToString(type),
      'amount': amount,
      'contact_id': contactId,   // Can be null
      'category_id': categoryId, // Can be null
      'note': note,              // Can be null
      'date': date.toIso8601String(),
      'transfer_to_bank_id': transferToBankId, // Only for transfers
    };
  }

  // Create from Map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      bankId: map['bank_id'] as String,
      type: _typeFromString(map['type'] as String),
      amount: (map['amount'] as num).toDouble(),
      contactId: map['contact_id'] as String?,
      categoryId: map['category_id'] as String?,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      transferToBankId: map['transfer_to_bank_id'] as String?,
    );
  }

  /// Whether this transaction adds money to the bank account
  bool get isCredit => type == TransactionType.credit;

  /// Whether this transaction removes money from the bank account
  bool get isDebit => type == TransactionType.debit;

  @override
  String toString() =>
      'TransactionModel(id: $id, type: ${_typeToString(type)}, amount: $amount)';
}
