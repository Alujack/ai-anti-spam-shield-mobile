class ScanHistory {
  final String id;
  final String message;
  final bool isSpam;
  final double confidence;
  final String prediction;
  final DateTime scannedAt;
  final Map<String, dynamic>? details;

  ScanHistory({
    required this.id,
    required this.message,
    required this.isSpam,
    required this.confidence,
    required this.prediction,
    required this.scannedAt,
    this.details,
  });

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      id: json['id'],
      message: json['message'],
      isSpam: json['isSpam'] ?? false,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      prediction: json['prediction'] ?? '',
      scannedAt: DateTime.parse(json['scannedAt']),
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'isSpam': isSpam,
      'confidence': confidence,
      'prediction': prediction,
      'scannedAt': scannedAt.toIso8601String(),
      'details': details,
    };
  }
}

