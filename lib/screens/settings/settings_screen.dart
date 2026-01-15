import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditingProfile = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    try {
      await ref.read(authProvider.notifier).updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isEditingProfile = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: AppColors.danger,
                  ),
                );
                return;
              }

              try {
                await ref.read(authProvider.notifier).changePassword(
                  oldPassword: oldPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final settingsState = ref.watch(appSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Section
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        (user?.name?.isNotEmpty == true
                            ? user!.name![0].toUpperCase()
                            : user?.email[0].toUpperCase()) ?? '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Edit Profile Section
            if (_isEditingProfile) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Name',
                        hint: 'Enter your name',
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone',
                        hint: 'Enter your phone',
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditingProfile = false;
                                  // Reset values
                                  _nameController.text = user?.name ?? '';
                                  _phoneController.text = user?.phone ?? '';
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Account Settings
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: _buildSection(
                  title: 'Account',
                  isDark: isDark,
                  children: [
                    _buildSettingTile(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          _isEditingProfile = true;
                        });
                      },
                    ),
                    _buildSettingTile(
                      icon: Icons.lock,
                      title: 'Change Password',
                      isDark: isDark,
                      onTap: _showChangePasswordDialog,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // App Settings
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: _buildSection(
                title: 'App',
                isDark: isDark,
                children: [
                  _buildSettingTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    isDark: isDark,
                    trailing: Switch(
                      value: settingsState.notificationsEnabled,
                      onChanged: (value) {
                        ref.read(appSettingsProvider.notifier).setNotificationsEnabled(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(value ? 'Notifications enabled' : 'Notifications disabled'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                    onTap: null,
                  ),
                  _buildSettingTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    isDark: isDark,
                    trailing: Switch(
                      value: settingsState.isDarkMode,
                      onChanged: (value) {
                        ref.read(appSettingsProvider.notifier).toggleDarkMode(value);
                      },
                    ),
                    onTap: null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: _buildSection(
                title: 'About',
                isDark: isDark,
                children: [
                  _buildSettingTile(
                    icon: Icons.info_outline,
                    title: 'About App',
                    isDark: isDark,
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'AI Anti-Scam Shield',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(Icons.shield, size: 48, color: AppColors.primary),
                        children: const [
                          Text(
                            'AI-powered protection against scams, phishing, and spam messages.',
                          ),
                        ],
                      );
                    },
                  ),
                  _buildSettingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                      );
                    },
                  ),
                  _buildSettingTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: CustomButton(
                text: 'Logout',
                onPressed: _logout,
                icon: Icons.logout,
                backgroundColor: AppColors.danger,
              ),
            ),

            const SizedBox(height: 16),

            // Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary).withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    bool isDark = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDark = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
              trailing ?? Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

