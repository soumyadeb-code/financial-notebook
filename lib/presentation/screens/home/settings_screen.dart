// ============================================================
// settings_screen.dart
// Allows the user to change their name, change PIN,
// and toggle biometric login.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:local_auth/local_auth.dart';

import '../../../blocs/user/user_bloc.dart';
import '../../../blocs/user/user_event.dart';
import '../../../blocs/user/user_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.settings, style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18),
        ),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          final name =
              state is UserAuthenticated ? state.name : '';
          final biometricEnabled =
              state is UserAuthenticated ? state.biometricEnabled : false;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ----- Profile Card -----
              _ProfileCard(name: name),
              const SizedBox(height: 24),

              // ----- Settings Items -----
              _SettingsSection(
                title: 'Account',
                items: [
                  _SettingsItem(
                    icon: Icons.person_outline,
                    label: AppStrings.changeName,
                    onTap: () => _showChangeNameDialog(context, name),
                  ),
                  _SettingsItem(
                    icon: Icons.lock_outline,
                    label: AppStrings.changePin,
                    onTap: () => _showChangePinDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _SettingsSection(
                title: 'Security',
                items: [
                  _BiometricToggle(
                    enabled: biometricEnabled,
                    onChanged: (val) =>
                        context.read<UserBloc>().add(SetBiometricEnabled(val)),
                  ),
                ],
              ),


              _SettingsSection(
                title: 'About',
                items: [
                  _SettingsItem(
                    icon: Icons.info_outline,
                    label: '${AppStrings.appName} v1.0.0',
                    onTap: () {},
                    showArrow: false,
                  ),
                  _SettingsItem(
                    icon: Icons.favorite_outline,
                    label: 'Made with Flutter & BLoC',
                    onTap: () {},
                    showArrow: false,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangeNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppStrings.changeName, style: AppTextStyles.headingSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.bodyLarge,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context
                    .read<UserBloc>()
                    .add(UpdateName(controller.text.trim()));
                Navigator.pop(context);
              }
            },
            child: Text('Save',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context) {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title:
              Text(AppStrings.changePin, style: AppTextStyles.headingSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPinController,
                obscureText: true,
                maxLength: 6,
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyLarge,
                decoration: const InputDecoration(
                    hintText: 'Current PIN', counterText: ''),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPinController,
                obscureText: true,
                maxLength: 6,
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyLarge,
                decoration: const InputDecoration(
                    hintText: 'New 6-digit PIN', counterText: ''),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 8),
                Text(errorText!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.debit)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child:
                  Text('Cancel', style: AppTextStyles.bodyMedium),
            ),
            TextButton(
              onPressed: () {
                if (newPinController.text.length != 6) {
                  setState(() => errorText = 'New PIN must be 6 digits');
                  return;
                }
                context.read<UserBloc>().add(UpdatePin(
                      oldPin: oldPinController.text,
                      newPin: newPinController.text,
                    ));
                Navigator.pop(dialogContext);
              },
              child: Text('Update',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Helper Widgets for Settings
// ============================================================

class _ProfileCard extends StatelessWidget {
  final String name;
  const _ProfileCard({required this.name});

  @override
  Widget build(BuildContext context) {
    // Get initials from name
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              initials,
              style: AppTextStyles.headingLarge.copyWith(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.headingMedium),
              const SizedBox(height: 4),
              Text(
                '${name.toLowerCase().replaceAll(' ', '_')}\'s vault',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelLarge,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showArrow;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.accent, size: 22),
      title: Text(label, style: AppTextStyles.bodyLarge),
      trailing: showArrow
          ? Icon(Icons.arrow_forward_ios,
              color: AppColors.textHint, size: 14)
          : null,
    );
  }
}


// ============================================================
// _BiometricToggle — detects fingerprint / face, shows right UI
// ============================================================
class _BiometricToggle extends StatefulWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _BiometricToggle({required this.enabled, required this.onChanged});

  @override
  State<_BiometricToggle> createState() => _BiometricToggleState();
}

class _BiometricToggleState extends State<_BiometricToggle> {
  final LocalAuthentication _auth = LocalAuthentication();
  List<BiometricType> _available = [];
  bool _deviceSupported = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      final types = canCheck ? await _auth.getAvailableBiometrics() : <BiometricType>[];
      if (mounted) {
        setState(() {
          _deviceSupported = canCheck && isSupported;
          _available = types;
        });
      }
    } catch (_) {}
  }

  IconData get _icon {
    if (_available.contains(BiometricType.face)) return Icons.face_unlock_outlined;
    if (_available.contains(BiometricType.fingerprint) ||
        _available.contains(BiometricType.strong)) return Icons.fingerprint;
    return Icons.security_outlined;
  }

  String get _label {
    if (_available.contains(BiometricType.face) &&
        (_available.contains(BiometricType.fingerprint) ||
            _available.contains(BiometricType.strong))) {
      return 'Face ID & Fingerprint';
    }
    if (_available.contains(BiometricType.face)) return 'Face Recognition';
    if (_available.contains(BiometricType.fingerprint) ||
        _available.contains(BiometricType.strong)) return 'Fingerprint Login';
    return AppStrings.biometricLogin;
  }

  String get _subtitle {
    if (!_deviceSupported) return 'Not supported on this device';
    if (_available.isEmpty) return 'No biometrics enrolled on this device';
    if (_available.contains(BiometricType.face) &&
        (_available.contains(BiometricType.fingerprint) ||
            _available.contains(BiometricType.strong))) {
      return 'Use Face ID or Fingerprint to unlock the app';
    }
    if (_available.contains(BiometricType.face)) {
      return 'Use Face Recognition to unlock the app';
    }
    return 'Use your fingerprint to unlock the app';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(_icon, color: AppColors.accent, size: 26),
          title: Text(_label, style: AppTextStyles.bodyLarge),
          subtitle: Text(_subtitle, style: AppTextStyles.bodySmall),
          trailing: Switch(
            value: widget.enabled && _deviceSupported && _available.isNotEmpty,
            onChanged: _deviceSupported && _available.isNotEmpty
                ? widget.onChanged
                : null,
            activeColor: AppColors.accent,
          ),
        ),
        // Show individual biometric chips when multiple types available
        if (_deviceSupported && _available.length > 1)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              children: [
                if (_available.contains(BiometricType.fingerprint) ||
                    _available.contains(BiometricType.strong))
                  _BiometricChip(
                    icon: Icons.fingerprint,
                    label: 'Fingerprint',
                    color: AppColors.accent,
                  ),
                const SizedBox(width: 8),
                if (_available.contains(BiometricType.face))
                  _BiometricChip(
                    icon: Icons.face_unlock_outlined,
                    label: 'Face ID',
                    color: AppColors.accentLight,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BiometricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _BiometricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
