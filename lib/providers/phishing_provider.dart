import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/phishing_result.dart';
import '../services/api_service.dart';

/// Phishing scan state
class PhishingState {
  final PhishingResult? result;
  final bool isLoading;
  final String? error;
  final List<PhishingScanHistory> history;
  final PhishingStatistics? statistics;

  PhishingState({
    this.result,
    this.isLoading = false,
    this.error,
    this.history = const [],
    this.statistics,
  });

  PhishingState copyWith({
    PhishingResult? result,
    bool? isLoading,
    String? error,
    List<PhishingScanHistory>? history,
    PhishingStatistics? statistics,
  }) {
    return PhishingState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      history: history ?? this.history,
      statistics: statistics ?? this.statistics,
    );
  }
}

/// Phishing provider notifier - using Riverpod 3.x Notifier
class PhishingNotifier extends Notifier<PhishingState> {
  late final ApiService _apiService;

  @override
  PhishingState build() {
    _apiService = ApiService();
    return PhishingState();
  }

  /// Scan text for phishing
  Future<PhishingResult?> scanText(String text, {String scanType = 'auto'}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.scanTextForPhishing(text, scanType: scanType);

      if (response['status'] == 'success' && response['data'] != null) {
        final result = PhishingResult.fromJson(response['data']);
        state = state.copyWith(result: result, isLoading: false);
        return result;
      } else {
        throw Exception(response['message'] ?? 'Phishing scan failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.getErrorMessage(e),
      );
      return null;
    }
  }

  /// Scan URL for phishing
  Future<PhishingResult?> scanUrl(String url) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.scanUrlForPhishing(url);

      if (response['status'] == 'success' && response['data'] != null) {
        final result = PhishingResult.fromJson(response['data']);
        state = state.copyWith(result: result, isLoading: false);
        return result;
      } else {
        throw Exception(response['message'] ?? 'URL scan failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.getErrorMessage(e),
      );
      return null;
    }
  }

  /// Get phishing scan history
  Future<void> loadHistory({int page = 1, int limit = 20}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getPhishingHistory(page: page, limit: limit);

      if (response['status'] == 'success' && response['data'] != null) {
        final histories = (response['data']['histories'] as List)
            .map((h) => PhishingScanHistory.fromJson(h))
            .toList();
        state = state.copyWith(history: histories, isLoading: false);
      } else {
        throw Exception(response['message'] ?? 'Failed to load history');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.getErrorMessage(e),
      );
    }
  }

  /// Get phishing statistics
  Future<void> loadStatistics() async {
    try {
      final response = await _apiService.getPhishingStatistics();

      if (response['status'] == 'success' && response['data'] != null) {
        final statistics = PhishingStatistics.fromJson(response['data']);
        state = state.copyWith(statistics: statistics);
      }
    } catch (e) {
      // Non-blocking error for statistics
    }
  }

  /// Delete a phishing scan from history
  Future<bool> deleteHistoryItem(String id) async {
    try {
      final response = await _apiService.deletePhishingHistory(id);

      if (response['status'] == 'success') {
        state = state.copyWith(
          history: state.history.where((h) => h.id != id).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clear current result
  void clearResult() {
    state = state.copyWith(result: null, error: null);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = PhishingState();
  }
}

/// Phishing provider
final phishingProvider = NotifierProvider<PhishingNotifier, PhishingState>(() {
  return PhishingNotifier();
});

/// Phishing statistics provider (auto-refresh)
final phishingStatisticsProvider = FutureProvider<PhishingStatistics?>((ref) async {
  final apiService = ApiService();

  try {
    final response = await apiService.getPhishingStatistics();

    if (response['status'] == 'success' && response['data'] != null) {
      return PhishingStatistics.fromJson(response['data']);
    }
  } catch (e) {
    // Return null on error
  }

  return null;
});
