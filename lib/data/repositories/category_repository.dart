// ============================================================
// category_repository.dart
// Handles all category database operations.
// Also seeds default categories on first run.
//
// SQLite table: categories
//   id, name, emoji, color (stored as integer ARGB)
// ============================================================

import 'package:uuid/uuid.dart';

import '../../core/storage/database_service.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final DatabaseService _db;

  CategoryRepository(this._db);

  // ── Read ─────────────────────────────────────────────────
  /// Returns all categories.
  Future<List<CategoryModel>> loadCategories() async {
    final rows = await _db.getAll('categories', orderBy: 'name ASC');
    return rows.map(CategoryModel.fromMap).toList();
  }

  // ── Write ─────────────────────────────────────────────────
  /// Adds a new category.
  Future<void> addCategory(CategoryModel category) async {
    await _db.insert('categories', category.toMap());
  }

  /// Permanently deletes a category.
  Future<void> deleteCategory(String id) async {
    await _db.delete('categories', id: id);
  }

  /// Updates an existing category.
  Future<void> updateCategory(CategoryModel category) async {
    await _db.updateWhere('categories', category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }

  // ── Seeding ───────────────────────────────────────────────
  /// Checks if default categories exist; if not, inserts them.
  /// Called once during app initialization (from CategoryBloc).
  Future<void> seedDefaultCategoriesIfNeeded(bool alreadySeeded) async {
    if (alreadySeeded) return; // Don't seed twice

    // Check if there are already categories in the DB
    final existing = await loadCategories();
    if (existing.isNotEmpty) return;

    // Default categories every new user gets
    final defaults = [
      _makeCategory('🍕', 'Food & Dining',    0xFFEF4444),
      _makeCategory('🚗', 'Transport',         0xFF3B82F6),
      _makeCategory('🛒', 'Shopping',          0xFFF59E0B),
      _makeCategory('💊', 'Health',            0xFF10B981),
      _makeCategory('🎬', 'Entertainment',     0xFF8B5CF6),
      _makeCategory('🏠', 'Rent & Housing',    0xFF6366F1),
      _makeCategory('📱', 'Bills & Utilities', 0xFFEC4899),
      _makeCategory('✈️', 'Travel',            0xFF06B6D4),
      _makeCategory('📚', 'Education',         0xFF84CC16),
      _makeCategory('💰', 'Income',            0xFF22C55E),
      _makeCategory('🎁', 'Gifts',             0xFFF97316),
      _makeCategory('💼', 'Business',          0xFF64748B),
      // User-requested categories
      _makeCategory('🧮', 'Accounting',        0xFF0EA5E9), // Abacus
      _makeCategory('🌐', 'Online & Web',      0xFF7C3AED), // Website / Internet
    ];

    // Insert all defaults in one batch for speed
    final db = await _db.database;
    final batch = db.batch();
    for (final cat in defaults) {
      batch.insert('categories', cat.toMap());
    }
    await batch.commit(noResult: true);
  }

  /// Helper to create a CategoryModel with a generated UUID
  CategoryModel _makeCategory(String emoji, String name, int color) {
    return CategoryModel(
      id: const Uuid().v4(),
      name: name,
      emoji: emoji,
      colorValue: color,
    );
  }
}
