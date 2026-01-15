import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_history.dart';
import '../services/api_service.dart';

// History State
class HistoryState {
  final List<ScanHistory> histories;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  HistoryState({
    this.histories = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  HistoryState copyWith({
    List<ScanHistory>? histories,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return HistoryState(
      histories: histories ?? this.histories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// History Notifier - using Riverpod 3.x Notifier
class HistoryNotifier extends Notifier<HistoryState> {
  late final ApiService _apiService;

  @override
  HistoryState build() {
    _apiService = ApiService();
    return HistoryState();
  }

  Future<void> loadHistory({int page = 1, int limit = 20, bool? isSpam}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.getScanHistory(
        page: page,
        limit: limit,
        isSpam: isSpam,
      );

      final histories = result['histories'] as List<ScanHistory>;
      state = state.copyWith(
        histories: histories,
        isLoading: false,
        currentPage: page,
        hasMore: histories.length >= limit,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.getErrorMessage(e),
      );
    }
  }

  Future<void> deleteHistory(String id) async {
    try {
      await _apiService.deleteScanHistory(id);
      state = state.copyWith(
        histories: state.histories.where((h) => h.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: _apiService.getErrorMessage(e));
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// History Provider
final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(() {
  return HistoryNotifier();
});
