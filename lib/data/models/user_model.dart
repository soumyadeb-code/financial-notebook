// ============================================================
// user_model.dart
// Represents the app user (you!).
// Stores your name, hashed PIN, and preferences.
// ============================================================

class UserModel {
  final String name;              // e.g., "Soumyadeb Dutta"
  final String pinHash;           // SHA-256 hash of the 6-digit PIN
  final bool biometricEnabled;    // Whether Face ID / Fingerprint is on
  final bool categoriesSeeded;    // Whether default categories were inserted

  const UserModel({
    required this.name,
    required this.pinHash,
    this.biometricEnabled = false,
    this.categoriesSeeded = false,
  });

  // ── SQLite serialization ──────────────────────────────────
  // SQLite doesn't have a boolean type, so we store true/false as 1/0

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'pin_hash': pinHash,
      'biometric_enabled': biometricEnabled ? 1 : 0,
      'categories_seeded': categoriesSeeded ? 1 : 0,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String? ?? '',
      pinHash: map['pin_hash'] as String? ?? '',
      // SQLite stores booleans as 1/0 integers
      biometricEnabled: (map['biometric_enabled'] as int? ?? 0) == 1,
      categoriesSeeded: (map['categories_seeded'] as int? ?? 0) == 1,
    );
  }

  UserModel copyWith({
    String? name,
    String? pinHash,
    bool? biometricEnabled,
    bool? categoriesSeeded,
  }) {
    return UserModel(
      name: name ?? this.name,
      pinHash: pinHash ?? this.pinHash,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      categoriesSeeded: categoriesSeeded ?? this.categoriesSeeded,
    );
  }

  @override
  String toString() => 'UserModel(name: $name, biometric: $biometricEnabled)';
}
