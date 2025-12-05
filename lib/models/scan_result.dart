class ScanResult {
  final bool isSpam;
  final double confidence;
  final String prediction;
  final String message;
  final String timestamp;
  final Map<String, dynamic>? details;

  ScanResult({
    required this.isSpam,
    required this.confidence,
    required this.prediction,
    required this.message,
    required this.timestamp,
    this.details,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      isSpam: json['is_spam'] ?? false,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      prediction: json['prediction'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_spam': isSpam,
      'confidence': confidence,
      'prediction': prediction,
      'message': message,
      'timestamp': timestamp,
      'details': details,
    };
  }
}

