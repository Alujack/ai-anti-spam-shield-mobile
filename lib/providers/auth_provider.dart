import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final user = await StorageService.getUser();
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authResponse = await _apiService.login(
        email: email,
        password: password,
      );
      state = AuthState(user: authResponse.user, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, error: _apiService.getErrorMessage(e));
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authResponse = await _apiService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      state = AuthState(user: authResponse.user, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, error: _apiService.getErrorMessage(e));
      rethrow;
    }
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    try {
      final user = await _apiService.updateProfile(name: name, phone: phone);
      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: _apiService.getErrorMessage(e));
      rethrow;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _apiService.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    await _apiService.logout();
    state = AuthState();
  }
}

// Auth Provider - named authProvider for use in screens
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ApiService();
  return AuthNotifier(apiService);
});
