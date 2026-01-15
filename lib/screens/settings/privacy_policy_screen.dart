import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/colors.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: January 2025',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Information We Collect',
                'We collect information you provide directly to us, such as when you create an account, scan messages for spam detection, or contact us for support. This includes:\n\n'
                    '• Account information (email, name, phone number)\n'
                    '• Message content submitted for scanning\n'
                    '• Voice recordings submitted for analysis\n'
                    '• Device information and usage statistics',
                isDark,
              ),
              _buildSection(
                'How We Use Your Information',
                'We use the information we collect to:\n\n'
                    '• Provide, maintain, and improve our spam detection services\n'
                    '• Process and analyze messages for spam/scam content\n'
                    '• Train and improve our AI models\n'
                    '• Send you notifications about scan results\n'
                    '• Respond to your comments and questions',
                isDark,
              ),
              _buildSection(
                'Data Security',
                'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. All data transmissions are encrypted using industry-standard protocols.',
                isDark,
              ),
              _buildSection(
                'Data Retention',
                'We retain your scan history for a limited period to provide you with historical analysis. You can delete your scan history at any time from the app settings. Account information is retained until you delete your account.',
                isDark,
              ),
              _buildSection(
                'Your Rights',
                'You have the right to:\n\n'
                    '• Access your personal data\n'
                    '• Correct inaccurate data\n'
                    '• Delete your account and associated data\n'
                    '• Export your data\n'
                    '• Opt-out of notifications',
                isDark,
              ),
              _buildSection(
                'Contact Us',
                'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                    'support@aiantispamshield.com',
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
