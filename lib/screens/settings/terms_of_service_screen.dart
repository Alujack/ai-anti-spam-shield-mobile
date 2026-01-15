import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/colors.dart';

class TermsOfServiceScreen extends ConsumerWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
                'Terms of Service',
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
                '1. Acceptance of Terms',
                'By accessing or using the AI Anti-Scam Shield application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our service.',
                isDark,
              ),
              _buildSection(
                '2. Description of Service',
                'AI Anti-Scam Shield provides an AI-powered service to detect spam, scam, and phishing messages. The service analyzes text and voice messages submitted by users and provides a classification of potential threats.',
                isDark,
              ),
              _buildSection(
                '3. User Accounts',
                'To use our service, you must create an account. You are responsible for:\n\n'
                    '• Maintaining the confidentiality of your account credentials\n'
                    '• All activities that occur under your account\n'
                    '• Notifying us immediately of any unauthorized use',
                isDark,
              ),
              _buildSection(
                '4. Acceptable Use',
                'You agree not to:\n\n'
                    '• Use the service for any unlawful purpose\n'
                    '• Submit content that violates others\' rights\n'
                    '• Attempt to circumvent security measures\n'
                    '• Interfere with the proper functioning of the service\n'
                    '• Reverse engineer or attempt to extract source code',
                isDark,
              ),
              _buildSection(
                '5. Disclaimer of Warranties',
                'The service is provided "as is" without warranties of any kind. While we strive for accuracy, we cannot guarantee that all spam or scam messages will be detected, or that all legitimate messages will be correctly classified.',
                isDark,
              ),
              _buildSection(
                '6. Limitation of Liability',
                'To the maximum extent permitted by law, AI Anti-Scam Shield shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service.',
                isDark,
              ),
              _buildSection(
                '7. Changes to Terms',
                'We reserve the right to modify these terms at any time. We will notify users of any material changes via the app or email. Continued use of the service after changes constitutes acceptance of the new terms.',
                isDark,
              ),
              _buildSection(
                '8. Termination',
                'We may terminate or suspend your account at any time for violations of these terms. You may also delete your account at any time through the app settings.',
                isDark,
              ),
              _buildSection(
                '9. Contact',
                'For questions about these Terms of Service, please contact us at:\n\n'
                    'legal@aiantispamshield.com',
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
