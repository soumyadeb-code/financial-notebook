// ============================================================
// enter_name_screen.dart
// The onboarding screen where the user enters their name.
// Called only on first launch.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/user/user_bloc.dart';
import '../../../blocs/user/user_event.dart';
import '../../../blocs/user/user_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../onboarding/security_pin_screen.dart';

class EnterNameScreen extends StatefulWidget {
  const EnterNameScreen({super.key});

  @override
  State<EnterNameScreen> createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Slide up animation for the content
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // Start 30% below
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserNeedsPinSetup) {
          // Name saved → go to PIN setup
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SecurityPinScreen(
                mode: PinMode.setup,
                userName: state.name,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // ----- Emoji -----
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child:
                          Text('👋', style: TextStyle(fontSize: 36)),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ----- Welcome Title -----
                  Text(
                    AppStrings.welcomeTitle,
                    style: AppTextStyles.headingLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tell us your name to personalize\nyour finance tracker.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 48),

                  // ----- Name Input -----
                  Text(
                    AppStrings.enterNameLabel.toUpperCase(),
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    style: AppTextStyles.headingMedium,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: AppStrings.enterNameHint,
                      hintStyle: AppTextStyles.bodyMedium,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // ----- Continue Button -----
                  AppButton(
                    label: AppStrings.continueButton,
                    onTap: _onContinue,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    // Send SaveName event to UserBloc
    context.read<UserBloc>().add(SaveName(name));
  }
}
