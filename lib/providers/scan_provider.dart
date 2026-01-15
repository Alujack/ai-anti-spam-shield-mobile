import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_result.dart';
import '../services/api_service.dart';

// Scan State
class ScanState {
  final ScanResult? result;
  final bool isLoading;
  final String? error;

  ScanState({
    this.result,
    this.isLoading = false,
    this.error,
  });

  ScanState copyWith({
    ScanResult? result,
    bool? isLoading,
    String? error,
  }) {
    return ScanState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Scan Provider - using Riverpod 3.x Notifier
class ScanNotifier extends Notifier<ScanState> {
  late final ApiService _apiService;

  @override
  ScanState build() {
    _apiService = ApiService();
    return ScanState();
  }

  Future<void> scanText(String message) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.scanText(message);
      state = state.copyWith(result: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.getErrorMessage(e),
      );
      rethrow;
    }
  }

  Future<void> scanVoice(String audioPath) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.scanVoice(audioPath);
      state = state.copyWith(result: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.getErrorMessage(e),
      );
      rethrow;
    }
  }

  void clearResult() {
    state = ScanState();
  }
}

final scanProvider = NotifierProvider<ScanNotifier, ScanState>(() {
  return ScanNotifier();
});

// Scan Statistics Provider
final scanStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ApiService();
  return await apiService.getScanStatistics();
});

