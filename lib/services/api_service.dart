import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/scan_result.dart';
import '../models/scan_history.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.timeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.timeout),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptor for auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle errors
        return handler.next(error);
      },
    ));
  }

  // Authentication Endpoints
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('/users/register', data: {
        'email': email,
        'password': password,
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      });

      final authResponse = AuthResponse.fromJson(response.data['data']);
      
      // Save tokens and user
      await StorageService.saveToken(authResponse.token);
      await StorageService.saveRefreshToken(authResponse.refreshToken);
      await StorageService.saveUser(authResponse.user);
      
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/users/login', data: {
        'email': email,
        'password': password,
      });

      final authResponse = AuthResponse.fromJson(response.data['data']);
      
      // Save tokens and user
      await StorageService.saveToken(authResponse.token);
      await StorageService.saveRefreshToken(authResponse.refreshToken);
      await StorageService.saveUser(authResponse.user);
      
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return User.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfile({String? name, String? phone}) async {
    try {
      final response = await _dio.put('/users/profile', data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      });
      
      final user = User.fromJson(response.data['data']);
      await StorageService.saveUser(user);
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post('/users/change-password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Message Scanning Endpoints
  Future<ScanResult> scanText(String message) async {
    try {
      final response = await _dio.post('/messages/scan-text', data: {
        'message': message,
      });

      return ScanResult.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<ScanResult> scanVoice(String audioPath) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: audioPath.split('/').last,
        ),
      });

      final response = await _dio.post('/messages/scan-voice', data: formData);

      return ScanResult.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getScanHistory({
    int page = 1,
    int limit = 20,
    bool? isSpam,
  }) async {
    try {
      final response = await _dio.get(
        '/messages/history',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (isSpam != null) 'isSpam': isSpam,
        },
      );

      final data = response.data['data'];
      return {
        'histories': (data['histories'] as List)
            .map((json) => ScanHistory.fromJson(json))
            .toList(),
        'pagination': data['pagination'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<ScanHistory> getScanHistoryById(String id) async {
    try {
      final response = await _dio.get('/messages/history/$id');
      return ScanHistory.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteScanHistory(String id) async {
    try {
      await _dio.delete('/messages/history/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getScanStatistics() async {
    try {
      final response = await _dio.get('/messages/statistics');
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await StorageService.clearAll();
  }

  // Error handling helper
  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final message = error.response?.data['message'];
        return message ?? 'An error occurred';
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return 'Connection timeout';
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return 'Receive timeout';
      } else if (error.type == DioExceptionType.connectionError) {
        return 'Connection error. Please check your internet connection.';
      }
      return 'Network error occurred';
    }
    return 'An unexpected error occurred';
  }
}

