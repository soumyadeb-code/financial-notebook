import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark);

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      AppColors.isLightMode = true;
      emit(ThemeMode.light);
    } else {
      AppColors.isLightMode = false;
      emit(ThemeMode.dark);
    }
  }
}
