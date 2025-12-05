import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// API Service Provider
final apiServiceProvider = Provider((ref) => ApiService());

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(const AsyncValue.loading()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final user = await StorageService.getUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authResponse = await _apiService.login(
        email: email,
        password: password,
      );
      state = AsyncValue.data(authResponse.user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final authResponse = await _apiService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      state = AsyncValue.data(authResponse.user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    try {
      final user = await _apiService.updateProfile(name: name, phone: phone);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    state = const AsyncValue.data(null);
  }
}

// Loading State Provider
final loadingProvider = StateProvider<bool>((ref) => false);

// Error Message Provider
final errorMessageProvider = StateProvider<String?>((ref) => null);

