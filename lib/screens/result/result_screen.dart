import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/scan_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (scanState.result == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
          title: const Text('Scan Result', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Text(
            'No scan result available',
            style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
      );
    }

    final result = scanState.result!;
    final isSpam = result.isSpam;
    final confidence = (result.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
        elevation: 0,
        title: const Text(
          'Scan Result',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result Icon and Status
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSpam
                        ? [AppColors.danger.withOpacity(0.1), AppColors.danger.withOpacity(0.05)]
                        : [AppColors.success.withOpacity(0.1), AppColors.success.withOpacity(0.05)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Icon
                    ZoomIn(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isSpam ? AppColors.danger : AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isSpam ? AppColors.danger : AppColors.success).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          isSpam ? Icons.warning_rounded : Icons.check_circle_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Status
                    Text(
                      isSpam ? 'SPAM DETECTED!' : 'SAFE MESSAGE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isSpam ? AppColors.danger : AppColors.success,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Confidence
                    Text(
                      'Confidence: $confidence%',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Voice Scan Indicator (if applicable)
            if (result.isVoiceScan) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 650),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mic, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Voice message scanned and transcribed',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Transcribed Text (for voice scans)
            if (result.isVoiceScan && result.transcribedText != null) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: _buildSection(
                  title: 'Transcribed Voice Message',
                  icon: Icons.record_voice_over,
                  isDark: isDark,
                  child: Text(
                    result.transcribedText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Message Preview (for text scans or fallback)
            if (!result.isVoiceScan || result.message.isNotEmpty)
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: _buildSection(
                  title: result.isVoiceScan ? 'Original Message' : 'Message',
                  icon: Icons.message,
                  isDark: isDark,
                  child: Text(
                    result.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Analysis Details
            if (result.details != null) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: _buildSection(
                  title: 'Analysis Details',
                  icon: Icons.analytics,
                  isDark: isDark,
                  child: Column(
                    children: [
                      _buildDetailRow('Prediction', result.prediction.toUpperCase(), isDark),
                      _buildDetailRow('Confidence', '${(result.confidence * 100).toStringAsFixed(1)}%', isDark),
                      if (result.details!['features'] != null) ...[
                        const Divider(height: 24),
                        _buildFeaturesSection(result.details!['features'], isDark),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Risk Indicators
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: _buildSection(
                title: 'Risk Indicators',
                icon: Icons.flag,
                isDark: isDark,
                child: _buildRiskIndicators(result, isDark),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: Column(
                children: [
                  if (isSpam)
                    CustomButton(
                      text: 'Report This Message',
                      onPressed: () {
                        _showReportDialog(context, result.message);
                      },
                      icon: Icons.report,
                      backgroundColor: AppColors.danger,
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    label: const Text(
                      'Scan Another Message',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tips
            if (isSpam)
              FadeInUp(
                duration: const Duration(milliseconds: 1100),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info, color: AppColors.warning, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Do not respond to this message, click any links, or provide personal information. Block the sender and delete the message.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
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
    required IconData icon,
    required Widget child,
    bool isDark = false,
  }) {
    return Container(
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
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(Map<String, dynamic> features, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features Detected:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (features['has_url'] == true) _buildFeatureChip('Contains URL', Icons.link, isDark),
        if (features['has_email'] == true) _buildFeatureChip('Contains Email', Icons.email, isDark),
        if (features['has_phone'] == true) _buildFeatureChip('Contains Phone', Icons.phone, isDark),
        if (features['urgency_words'] == true) _buildFeatureChip('Urgency Words', Icons.warning, isDark),
        if (features['spam_keywords'] == true) _buildFeatureChip('Spam Keywords', Icons.block, isDark),
        if (features['currency_symbols'] == true) _buildFeatureChip('Money Symbols', Icons.attach_money, isDark),
      ],
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.danger),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskIndicators(result, bool isDark) {
    final List<Map<String, dynamic>> indicators = [];

    if (result.details != null && result.details!['features'] != null) {
      final features = result.details!['features'];

      if (features['urgency_words'] == true) {
        indicators.add({
          'title': 'Urgency Tactics',
          'desc': 'Uses urgent language to pressure action',
        });
      }
      if (features['spam_keywords'] == true) {
        indicators.add({
          'title': 'Common Spam Words',
          'desc': 'Contains typical spam keywords',
        });
      }
      if (features['has_url'] == true) {
        indicators.add({
          'title': 'Suspicious Links',
          'desc': 'Contains URLs that may be dangerous',
        });
      }
    }

    if (indicators.isEmpty) {
      return Text(
        'No specific risk indicators detected',
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      );
    }

    return Column(
      children: indicators.map((indicator) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error, color: AppColors.danger, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      indicator['title'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      indicator['desc'],
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showReportDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Message'),
        content: const Text('Are you sure you want to report this message as spam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message reported successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}

