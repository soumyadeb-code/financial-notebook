// ============================================================
// splash_screen.dart
// The first screen shown when the app opens.
// Shows the logo + app name with animations, then routes
// the user to the correct next screen based on their setup.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/user/user_bloc.dart';
import '../../../blocs/user/user_event.dart';
import '../../../blocs/user/user_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../onboarding/enter_name_screen.dart';
import '../onboarding/security_pin_screen.dart';
import '../../screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // AnimationController drives all our animations
  late AnimationController _controller;

  // Fade-in animation for the logo
  late Animation<double> _fadeAnimation;

  // Scale animation for the logo (pops in from small to full size)
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animation that runs for 1.5 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Logo fades from 0 (invisible) to 1 (fully visible) in the first 600ms
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Logo scales from 0.7 to 1.0 in the first 600ms
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Start the animation
    _controller.forward();

    // After 2 seconds, load user data and navigate
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        context.read<UserBloc>().add(const LoadUser());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      // Listen for state changes and navigate accordingly
      listener: (context, state) {
        if (state is UserNotSetup) {
          // No user → Enter Name screen
          _navigateTo(context, const EnterNameScreen());
        } else if (state is UserNeedsPinSetup) {
          // Has name but no PIN → PIN setup
          _navigateTo(
            context,
            SecurityPinScreen(mode: PinMode.setup, userName: state.name),
          );
        } else if (state is UserNeedsPinVerification) {
          // Has everything → PIN verification (login)
          _navigateTo(
            context,
            SecurityPinScreen(
              mode: PinMode.verify,
              userName: state.name,
              biometricEnabled: state.biometricEnabled,
            ),
          );
        } else if (state is UserAuthenticated) {
          _navigateTo(context, const HomeScreen());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ----- App Logo -----
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: AppColors.purpleGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('💰',
                              style: TextStyle(fontSize: 44)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ----- App Name -----
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.headingLarge.copyWith(
                          fontSize: 32,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ----- Tagline -----
                      Text(
                        AppStrings.appTagline,
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 60),

                      // ----- Loading Indicator -----
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accent.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Navigate to a new screen, replacing the splash screen
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: const Duration(milliseconds: 500),
        // Fade transition between splash and next screen
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
