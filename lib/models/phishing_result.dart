/// Phishing Detection Result Models
/// Contains data classes for phishing detection API responses

/// URL analysis result from phishing detection
class URLAnalysis {
  final String url;
  final bool isSuspicious;
  final double score;
  final List<String> reasons;

  URLAnalysis({
    required this.url,
    required this.isSuspicious,
    required this.score,
    required this.reasons,
  });

  factory URLAnalysis.fromJson(Map<String, dynamic> json) {
    return URLAnalysis(
      url: json['url'] ?? '',
      isSuspicious: json['is_suspicious'] ?? false,
      score: (json['score'] ?? 0).toDouble(),
      reasons: List<String>.from(json['reasons'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'is_suspicious': isSuspicious,
      'score': score,
      'reasons': reasons,
    };
  }
}

/// Brand impersonation detection result
class BrandImpersonation {
  final bool detected;
  final String? brand;
  final double similarityScore;

  BrandImpersonation({
    required this.detected,
    this.brand,
    required this.similarityScore,
  });

  factory BrandImpersonation.fromJson(Map<String, dynamic> json) {
    return BrandImpersonation(
      detected: json['detected'] ?? false,
      brand: json['brand'],
      similarityScore: (json['similarity_score'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detected': detected,
      'brand': brand,
      'similarity_score': similarityScore,
    };
  }
}

/// Threat level enumeration
enum ThreatLevel {
  critical,
  high,
  medium,
  low,
  none,
}

extension ThreatLevelExtension on ThreatLevel {
  String get displayName {
    switch (this) {
      case ThreatLevel.critical:
        return 'CRITICAL';
      case ThreatLevel.high:
        return 'HIGH';
      case ThreatLevel.medium:
        return 'MEDIUM';
      case ThreatLevel.low:
        return 'LOW';
      case ThreatLevel.none:
        return 'NONE';
    }
  }

  static ThreatLevel fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CRITICAL':
        return ThreatLevel.critical;
      case 'HIGH':
        return ThreatLevel.high;
      case 'MEDIUM':
        return ThreatLevel.medium;
      case 'LOW':
        return ThreatLevel.low;
      default:
        return ThreatLevel.none;
    }
  }
}

/// Phishing type enumeration
enum PhishingType {
  email,
  sms,
  url,
  none,
}

extension PhishingTypeExtension on PhishingType {
  String get displayName {
    switch (this) {
      case PhishingType.email:
        return 'EMAIL';
      case PhishingType.sms:
        return 'SMS';
      case PhishingType.url:
        return 'URL';
      case PhishingType.none:
        return 'NONE';
    }
  }

  static PhishingType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'EMAIL':
        return PhishingType.email;
      case 'SMS':
        return PhishingType.sms;
      case 'URL':
        return PhishingType.url;
      default:
        return PhishingType.none;
    }
  }
}

/// Complete phishing detection result
class PhishingResult {
  final bool isPhishing;
  final double confidence;
  final PhishingType phishingType;
  final ThreatLevel threatLevel;
  final List<String> indicators;
  final List<URLAnalysis> urlsAnalyzed;
  final BrandImpersonation? brandImpersonation;
  final String recommendation;
  final Map<String, dynamic> details;
  final String timestamp;

  PhishingResult({
    required this.isPhishing,
    required this.confidence,
    required this.phishingType,
    required this.threatLevel,
    required this.indicators,
    required this.urlsAnalyzed,
    this.brandImpersonation,
    required this.recommendation,
    required this.details,
    required this.timestamp,
  });

  factory PhishingResult.fromJson(Map<String, dynamic> json) {
    return PhishingResult(
      isPhishing: json['isPhishing'] ?? json['is_phishing'] ?? false,
      confidence: (json['confidence'] ?? 0).toDouble(),
      phishingType: PhishingTypeExtension.fromString(
          json['phishingType'] ?? json['phishing_type'] ?? 'NONE'),
      threatLevel: ThreatLevelExtension.fromString(
          json['threatLevel'] ?? json['threat_level'] ?? 'NONE'),
      indicators: List<String>.from(json['indicators'] ?? []),
      urlsAnalyzed: (json['urlsAnalyzed'] ?? json['urls_analyzed'] ?? [])
          .map<URLAnalysis>((u) => URLAnalysis.fromJson(u))
          .toList(),
      brandImpersonation: json['brandImpersonation'] != null ||
              json['brand_impersonation'] != null
          ? BrandImpersonation.fromJson(
              json['brandImpersonation'] ?? json['brand_impersonation'])
          : null,
      recommendation: json['recommendation'] ?? '',
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPhishing': isPhishing,
      'confidence': confidence,
      'phishingType': phishingType.displayName,
      'threatLevel': threatLevel.displayName,
      'indicators': indicators,
      'urlsAnalyzed': urlsAnalyzed.map((u) => u.toJson()).toList(),
      'brandImpersonation': brandImpersonation?.toJson(),
      'recommendation': recommendation,
      'details': details,
      'timestamp': timestamp,
    };
  }

  /// Get confidence as percentage string
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  /// Check if there are any suspicious URLs
  bool get hasSuspiciousUrls => urlsAnalyzed.any((u) => u.isSuspicious);

  /// Get count of suspicious URLs
  int get suspiciousUrlCount =>
      urlsAnalyzed.where((u) => u.isSuspicious).length;

  /// Check if this is a high-risk result
  bool get isHighRisk =>
      threatLevel == ThreatLevel.critical || threatLevel == ThreatLevel.high;
}

/// Phishing scan history item
class PhishingScanHistory {
  final String id;
  final String inputText;
  final String? inputUrl;
  final bool isPhishing;
  final double confidence;
  final PhishingType phishingType;
  final ThreatLevel threatLevel;
  final List<String> indicators;
  final String? brandDetected;
  final DateTime scannedAt;

  PhishingScanHistory({
    required this.id,
    required this.inputText,
    this.inputUrl,
    required this.isPhishing,
    required this.confidence,
    required this.phishingType,
    required this.threatLevel,
    required this.indicators,
    this.brandDetected,
    required this.scannedAt,
  });

  factory PhishingScanHistory.fromJson(Map<String, dynamic> json) {
    return PhishingScanHistory(
      id: json['id'] ?? '',
      inputText: json['inputText'] ?? '',
      inputUrl: json['inputUrl'],
      isPhishing: json['isPhishing'] ?? false,
      confidence: (json['confidence'] ?? 0).toDouble(),
      phishingType: PhishingTypeExtension.fromString(
          json['phishingType'] ?? 'NONE'),
      threatLevel: ThreatLevelExtension.fromString(
          json['threatLevel'] ?? 'NONE'),
      indicators: List<String>.from(json['indicators'] ?? []),
      brandDetected: json['brandDetected'],
      scannedAt: json['scannedAt'] != null
          ? DateTime.parse(json['scannedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inputText': inputText,
      'inputUrl': inputUrl,
      'isPhishing': isPhishing,
      'confidence': confidence,
      'phishingType': phishingType.displayName,
      'threatLevel': threatLevel.displayName,
      'indicators': indicators,
      'brandDetected': brandDetected,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  /// Get confidence as percentage string
  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  /// Get truncated input text for display
  String get displayText =>
      inputText.length > 100 ? '${inputText.substring(0, 100)}...' : inputText;
}

/// Phishing statistics
class PhishingStatistics {
  final int totalScans;
  final int phishingDetected;
  final int safeScans;
  final double phishingPercentage;
  final Map<String, int> threatLevels;

  PhishingStatistics({
    required this.totalScans,
    required this.phishingDetected,
    required this.safeScans,
    required this.phishingPercentage,
    required this.threatLevels,
  });

  factory PhishingStatistics.fromJson(Map<String, dynamic> json) {
    return PhishingStatistics(
      totalScans: json['totalScans'] ?? 0,
      phishingDetected: json['phishingDetected'] ?? 0,
      safeScans: json['safeScans'] ?? 0,
      phishingPercentage: (json['phishingPercentage'] is String)
          ? double.tryParse(json['phishingPercentage']) ?? 0
          : (json['phishingPercentage'] ?? 0).toDouble(),
      threatLevels: Map<String, int>.from(json['threatLevels'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScans': totalScans,
      'phishingDetected': phishingDetected,
      'safeScans': safeScans,
      'phishingPercentage': phishingPercentage,
      'threatLevels': threatLevels,
    };
  }
}

/// Batch phishing scan result
class BatchPhishingResult {
  final List<PhishingResult> results;
  final int total;
  final int phishingDetected;
  final int safe;
  final Map<String, int> threatLevels;
  final String timestamp;

  BatchPhishingResult({
    required this.results,
    required this.total,
    required this.phishingDetected,
    required this.safe,
    required this.threatLevels,
    required this.timestamp,
  });

  factory BatchPhishingResult.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? {};
    return BatchPhishingResult(
      results: (json['results'] ?? [])
          .map<PhishingResult>((r) => PhishingResult.fromJson(r))
          .toList(),
      total: summary['total'] ?? 0,
      phishingDetected: summary['phishing_detected'] ?? summary['phishingDetected'] ?? 0,
      safe: summary['safe'] ?? 0,
      threatLevels: Map<String, int>.from(summary['threat_levels'] ?? summary['threatLevels'] ?? {}),
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }
}
