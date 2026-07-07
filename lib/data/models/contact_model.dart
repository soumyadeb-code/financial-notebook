// ============================================================
// contact_model.dart
// Represents a person/contact in the app.
// Used to tag who you paid or received money from.
// ============================================================

class ContactModel {
  final String id;    // Unique ID
  final String name;  // e.g., "Arya Sir", "Mom", "Netflix"

  const ContactModel({
    required this.id,
    required this.name,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Create from Map
  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  /// Returns the initials for the avatar circle
  /// Example: "Arya Sir" → "AS", "Netflix" → "N"
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    // Take first letter of first and last word
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  String toString() => 'ContactModel(id: $id, name: $name)';
}
