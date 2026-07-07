// ============================================================
// app.dart
// Defines the root MaterialApp widget.
// This is where we set the theme, app title, and starting route.
//
// The MaterialApp wraps everything in the app and provides:
//   - Theme (dark mode colors, fonts, etc.)
//   - Navigation context
//   - Localization setup
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'blocs/theme/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/screens/splash/splash_screen.dart';

class ExpenseVaultApp extends StatelessWidget {
  const ExpenseVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Make the status bar transparent so our dark background shows through
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons on dark bg
        systemNavigationBarColor: Color(0xFF1A1A2E),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Financial Notebook',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
