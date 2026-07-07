// ============================================================
// category_bloc.dart
// Manages categories in UI state.
// On LoadCategories, also seeds defaults if needed.
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/category_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;
  final UserRepository _userRepository;

  CategoryBloc({
    required CategoryRepository categoryRepository,
    required UserRepository userRepository,
  })  : _categoryRepository = categoryRepository,
        _userRepository = userRepository,
        super(const CategoryLoading()) {
    on<LoadCategories>(_onLoad);
    on<AddCategory>(_onAdd);
    on<DeleteCategory>(_onDelete);
    on<UpdateCategory>(_onUpdate);
  }

  Future<void> _onLoad(
      LoadCategories event, Emitter<CategoryState> emit) async {
    emit(const CategoryLoading());

    // Check if default categories were seeded yet
    final user = await _userRepository.loadUser();
    final alreadySeeded = user?.categoriesSeeded ?? false;

    // Seed defaults if first run (this is idempotent — safe to call again)
    await _categoryRepository.seedDefaultCategoriesIfNeeded(alreadySeeded);

    // Mark seeded in user row so we never seed again
    if (!alreadySeeded && user != null) {
      await _userRepository.markCategoriesSeeded();
    }

    final categories = await _categoryRepository.loadCategories();
    emit(CategoryLoaded(categories));
  }

  Future<void> _onAdd(AddCategory event, Emitter<CategoryState> emit) async {
    await _categoryRepository.addCategory(event.category);
    final categories = await _categoryRepository.loadCategories();
    emit(CategoryLoaded(categories));
  }

  Future<void> _onDelete(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    await _categoryRepository.deleteCategory(event.id);
    final categories = await _categoryRepository.loadCategories();
    emit(CategoryLoaded(categories));
  }

  Future<void> _onUpdate(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    await _categoryRepository.updateCategory(event.category);
    final categories = await _categoryRepository.loadCategories();
    emit(CategoryLoaded(categories));
  }
}
