class ScanResult {
  final bool isSpam;
  final double confidence;
  final String prediction;
  final String message;
  final String timestamp;
  final Map<String, dynamic>? details;
  final String? transcribedText; // For voice scans
  final bool isVoiceScan; // Indicates if this was a voice scan

  ScanResult({
    required this.isSpam,
    required this.confidence,
    required this.prediction,
    required this.message,
    required this.timestamp,
    this.details,
    this.transcribedText,
    this.isVoiceScan = false,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final transcribed = json['transcribed_text'];
    return ScanResult(
      isSpam: json['is_spam'] ?? false,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      prediction: json['prediction'] ?? '',
      message: json['message'] ?? transcribed ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      details: json['details'],
      transcribedText: transcribed,
      isVoiceScan: transcribed != null,
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
      if (transcribedText != null) 'transcribed_text': transcribedText,
      'is_voice_scan': isVoiceScan,
    };
  }
}

