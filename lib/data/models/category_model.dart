// ============================================================
// category_model.dart
// Represents a spending/earning category.
// e.g., 🍔 Food, 🚗 Transport, 💼 Salary
// ============================================================

import 'package:flutter/material.dart';

class CategoryModel {
  final String id;      // Unique ID
  final String name;    // e.g., "Food & Dining"
  final String emoji;   // e.g., "🍔"
  final int colorValue; // Color stored as an integer (e.g., 0xFFF59E0B)

  const CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? emoji,
    int? colorValue,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  /// Get the Flutter Color object from the stored integer
  Color get color => Color(colorValue);

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': colorValue,
    };
  }

  // Create from Map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      colorValue: map['color'] as int,
    );
  }

  /// Full display label: "🍔 Food & Dining"
  String get displayLabel => '$emoji $name';

  @override
  String toString() => 'CategoryModel(id: $id, name: $name, emoji: $emoji)';
}
