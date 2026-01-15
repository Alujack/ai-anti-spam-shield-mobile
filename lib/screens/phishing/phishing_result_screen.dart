import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/phishing_result.dart';
import '../../providers/phishing_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';

class PhishingResultScreen extends ConsumerWidget {
  const PhishingResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phishingState = ref.watch(phishingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (phishingState.result == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
          title: const Text('Phishing Analysis', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Text(
            'No phishing analysis available',
            style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
      );
    }

    final result = phishingState.result!;
    final isPhishing = result.isPhishing;
    final confidence = result.confidencePercentage;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
        elevation: 0,
        title: const Text(
          'Phishing Analysis',
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
            _buildStatusCard(result, isDark),

            const SizedBox(height: 24),

            // Threat Level Badge
            if (isPhishing) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 650),
                child: _buildThreatLevelBadge(result.threatLevel, isDark),
              ),
              const SizedBox(height: 16),
            ],

            // Phishing Type
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: _buildPhishingTypeCard(result.phishingType, isDark),
            ),

            const SizedBox(height: 16),

            // Detected Indicators
            if (result.indicators.isNotEmpty) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 750),
                child: _buildIndicatorsSection(result.indicators, isDark),
              ),
              const SizedBox(height: 16),
            ],

            // URL Analysis
            if (result.urlsAnalyzed.isNotEmpty) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: _buildUrlAnalysisSection(result.urlsAnalyzed, isDark),
              ),
              const SizedBox(height: 16),
            ],

            // Brand Impersonation Warning
            if (result.brandImpersonation != null) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 850),
                child: _buildBrandWarning(result.brandImpersonation!, isDark),
              ),
              const SizedBox(height: 16),
            ],

            // Recommendation
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: _buildRecommendationCard(result.recommendation, isPhishing, isDark),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            FadeInUp(
              duration: const Duration(milliseconds: 950),
              child: Column(
                children: [
                  if (isPhishing)
                    CustomButton(
                      text: 'Report This Message',
                      onPressed: () => _showReportDialog(context),
                      backgroundColor: AppColors.danger,
                      icon: Icons.flag_outlined,
                    ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Scan Another Message',
                    onPressed: () {
                      ref.read(phishingProvider.notifier).clearResult();
                      Navigator.pop(context);
                    },
                    isOutlined: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(PhishingResult result, bool isDark) {
    final isPhishing = result.isPhishing;
    final statusColor = _getThreatColor(result.threatLevel);

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPhishing
                ? [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)]
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
                  color: isPhishing ? statusColor : AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isPhishing ? statusColor : AppColors.success).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  isPhishing ? Icons.phishing_rounded : Icons.verified_user_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Status
            Text(
              isPhishing ? 'PHISHING DETECTED!' : 'SAFE MESSAGE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isPhishing ? statusColor : AppColors.success,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Confidence
            Text(
              'Confidence: ${result.confidencePercentage}',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreatLevelBadge(ThreatLevel level, bool isDark) {
    final color = _getThreatColor(level);
    final icon = _getThreatIcon(level);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(
            'Threat Level: ${level.displayName}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhishingTypeCard(PhishingType type, bool isDark) {
    final icon = _getPhishingTypeIcon(type);
    final label = _getPhishingTypeLabel(type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attack Type',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsSection(List<String> indicators, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
              const SizedBox(width: 8),
              Text(
                'Detected Indicators',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...indicators.map((indicator) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    indicator,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUrlAnalysisSection(List<URLAnalysis> urls, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'URL Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...urls.map((url) => _buildUrlItem(url, isDark)),
        ],
      ),
    );
  }

  Widget _buildUrlItem(URLAnalysis url, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: url.isSuspicious
            ? AppColors.danger.withOpacity(isDark ? 0.15 : 0.08)
            : AppColors.success.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                url.isSuspicious ? Icons.dangerous : Icons.check_circle_outline,
                color: url.isSuspicious ? AppColors.danger : AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  url.url.length > 40 ? '${url.url.substring(0, 40)}...' : url.url,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: url.isSuspicious ? AppColors.danger : AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(url.score * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (url.reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...url.reasons.map((reason) => Padding(
              padding: const EdgeInsets.only(left: 28, top: 4),
              child: Text(
                '- $reason',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildBrandWarning(BrandImpersonation brand, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.business, color: AppColors.warning, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Brand Impersonation Detected',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This message may be impersonating ${brand.brand?.toUpperCase() ?? "a known brand"}',
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
  }

  Widget _buildRecommendationCard(String recommendation, bool isPhishing, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPhishing
            ? AppColors.danger.withOpacity(isDark ? 0.15 : 0.08)
            : AppColors.success.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPhishing
              ? AppColors.danger.withOpacity(0.3)
              : AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPhishing ? Icons.shield_outlined : Icons.verified_outlined,
            color: isPhishing ? AppColors.danger : AppColors.success,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommendation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isPhishing ? AppColors.danger : AppColors.success,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getThreatColor(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.critical:
        return const Color(0xFFDC2626); // Red 600
      case ThreatLevel.high:
        return const Color(0xFFEA580C); // Orange 600
      case ThreatLevel.medium:
        return const Color(0xFFD97706); // Amber 600
      case ThreatLevel.low:
        return const Color(0xFF2563EB); // Blue 600
      case ThreatLevel.none:
        return AppColors.success;
    }
  }

  IconData _getThreatIcon(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.critical:
        return Icons.dangerous;
      case ThreatLevel.high:
        return Icons.warning_amber_rounded;
      case ThreatLevel.medium:
        return Icons.error_outline;
      case ThreatLevel.low:
        return Icons.info_outline;
      case ThreatLevel.none:
        return Icons.check_circle_outline;
    }
  }

  IconData _getPhishingTypeIcon(PhishingType type) {
    switch (type) {
      case PhishingType.email:
        return Icons.email_outlined;
      case PhishingType.sms:
        return Icons.sms_outlined;
      case PhishingType.url:
        return Icons.link;
      case PhishingType.none:
        return Icons.check_circle_outline;
    }
  }

  String _getPhishingTypeLabel(PhishingType type) {
    switch (type) {
      case PhishingType.email:
        return 'Email Phishing';
      case PhishingType.sms:
        return 'SMS Phishing (Smishing)';
      case PhishingType.url:
        return 'URL-based Phishing';
      case PhishingType.none:
        return 'No Threat Detected';
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Phishing'),
        content: const Text(
          'Would you like to report this message as a phishing attempt? '
          'This helps improve our detection system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! Report submitted successfully.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
