import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

// Scan History Provider
final scanHistoryProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
  (ref, params) async {
    final apiService = ref.read(apiServiceProvider);
    final page = params['page'] as int? ?? 1;
    final limit = params['limit'] as int? ?? 20;
    final isSpam = params['isSpam'] as bool?;

    return await apiService.getScanHistory(
      page: page,
      limit: limit,
      isSpam: isSpam,
    );
  },
);

// History Filter Provider
final historyFilterProvider = StateProvider<bool?>((ref) => null);

// History Page Provider
final historyPageProvider = StateProvider<int>((ref) => 1);

