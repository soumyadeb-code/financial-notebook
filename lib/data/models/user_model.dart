// ============================================================
// user_model.dart
// Represents the app user (you!).
// Stores your name, hashed PIN, and preferences.
// ============================================================

class UserModel {
  final String name;              // e.g., "Soumyadeb Dutta"
  final String pinHash;           // SHA-256 hash of the 6-digit PIN
  final bool categoriesSeeded;    // Whether default categories were inserted

  const UserModel({
    required this.name,
    required this.pinHash,
    this.categoriesSeeded = false,
  });

  // ── SQLite serialization ──────────────────────────────────
  // SQLite doesn't have a boolean type, so we store true/false as 1/0

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'pin_hash': pinHash,
      'categories_seeded': categoriesSeeded ? 1 : 0,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String? ?? '',
      pinHash: map['pin_hash'] as String? ?? '',
      categoriesSeeded: (map['categories_seeded'] as int? ?? 0) == 1,
    );
  }

  UserModel copyWith({
    String? name,
    String? pinHash,
    bool? categoriesSeeded,
  }) {
    return UserModel(
      name: name ?? this.name,
      pinHash: pinHash ?? this.pinHash,
      categoriesSeeded: categoriesSeeded ?? this.categoriesSeeded,
    );
  }

  @override
  String toString() => 'UserModel(name: $name)';
}
