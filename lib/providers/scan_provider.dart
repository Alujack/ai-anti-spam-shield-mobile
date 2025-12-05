import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_result.dart';
import 'auth_provider.dart';

// Current Scan Result Provider
final currentScanResultProvider = StateProvider<ScanResult?>((ref) => null);

// Scan Text Provider
final scanTextProvider = FutureProvider.family<ScanResult, String>((ref, message) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.scanText(message);
});

// Scan Statistics Provider
final scanStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getScanStatistics();
});

