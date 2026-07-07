// ============================================================
// security_pin_screen.dart
// The 6-digit PIN screen (setup & verify modes).
// FIX: Wrapped in SingleChildScrollView so the number pad doesn't
//      overflow when the keyboard appears on some devices.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/user/user_bloc.dart';
import '../../../blocs/user/user_event.dart';
import '../../../blocs/user/user_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../home/home_screen.dart';

enum PinMode { setup, verify }

class SecurityPinScreen extends StatefulWidget {
  final PinMode mode;
  final String userName;
  final bool biometricEnabled;

  const SecurityPinScreen({
    super.key,
    required this.mode,
    required this.userName,
    this.biometricEnabled = false,
  });

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  List<int> _pin = [];
  bool _isConfirming = false;
  List<int> _firstPin = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.mode == PinMode.verify && widget.biometricEnabled) {
      // Trigger biometric automatically when the screen opens
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserBloc>().add(const AuthenticateWithBiometric());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
          );
        } else if (state is PinVerificationFailed) {
          setState(() {
            _errorMessage = state.message;
            _pin = [];
          });
        }
      },
      // FIX: resizeToAvoidBottomInset: false prevents the "BOTTOM OVERFLOWED"
      // error when the system keyboard pushes up the Scaffold. Instead the
      // content is wrapped in a scroll view that handles the inset manually.
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ----- Lock Icon -----
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.accent, width: 1.5),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: AppColors.accent,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ----- Title -----
                        Text(
                          _isConfirming
                              ? AppStrings.confirmPinTitle
                              : (widget.mode == PinMode.setup
                                  ? AppStrings.setupPinTitle
                                  : AppStrings.verifyPinTitle),
                          style: AppTextStyles.headingLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isConfirming
                              ? AppStrings.confirmPinSubtitle
                              : (widget.mode == PinMode.setup
                                  ? AppStrings.setupPinSubtitle
                                  : '${AppStrings.verifyPinSubtitle}\nWelcome back, ${widget.userName}!'),
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),

                        // ----- 6 PIN Dots -----
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final isFilled = index < _pin.length;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFilled ? AppColors.accent : AppColors.border,
                                boxShadow: isFilled
                                    ? [
                                        BoxShadow(
                                          color: AppColors.accent.withOpacity(0.5),
                                          blurRadius: 8,
                                        )
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),

                        // ----- Error Message -----
                        SizedBox(
                          height: 24,
                          child: _errorMessage != null
                              ? Text(
                                  _errorMessage!,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.debit),
                                  textAlign: TextAlign.center,
                                )
                              : null,
                        ),
                        const SizedBox(height: 20), // Replaced Spacer()

                        // ----- Biometric Button (verify mode only) -----
                        if (widget.mode == PinMode.verify &&
                            widget.biometricEnabled) ...[
                          GestureDetector(
                            onTap: () => context
                                .read<UserBloc>()
                                .add(const AuthenticateWithBiometric()),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Icon(
                                    Icons.face_outlined,
                                    color: AppColors.accent,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.orUseBiometric,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // ----- Number Pad -----
                        _buildNumberPad(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

  }

  Widget _buildNumberPad() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.7,
      ),
      itemCount: 12,
      itemBuilder: (_, index) {
        if (index == 9) return const SizedBox();
        if (index == 10) return _buildPadButton('0');
        if (index == 11) return _buildBackspaceButton();
        return _buildPadButton('${index + 1}');
      },
    );
  }

  Widget _buildPadButton(String digit) {
    return GestureDetector(
      onTap: () => _onDigitTap(int.parse(digit)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.backspace_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  void _onDigitTap(int digit) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin = [..._pin, digit];
      _errorMessage = null;
    });
    if (_pin.length == 6) _processPIN();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.sublist(0, _pin.length - 1));
  }

  void _processPIN() {
    final pinString = _pin.join();
    if (widget.mode == PinMode.setup) {
      if (!_isConfirming) {
        setState(() {
          _firstPin = List.from(_pin);
          _pin = [];
          _isConfirming = true;
        });
      } else {
        if (_pin.join() == _firstPin.join()) {
          context.read<UserBloc>().add(SavePin(pinString));
        } else {
          setState(() {
            _errorMessage = AppStrings.pinMismatch;
            _pin = [];
            _firstPin = [];
            _isConfirming = false;
          });
        }
      }
    } else {
      context.read<UserBloc>().add(VerifyPin(pinString));
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _pin = []);
      });
    }
  }
}
