// ============================================================
// category_event.dart
// ============================================================

import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

class AddCategory extends CategoryEvent {
  final CategoryModel category;
  const AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final String id;
  const DeleteCategory(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateCategory extends CategoryEvent {
  final CategoryModel category;
  const UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}
