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
      // Determine content type based on file extension
      final filename = audioPath.split('/').last;
      final extension = filename.split('.').last.toLowerCase();
      String contentType;
      switch (extension) {
        case 'm4a':
        case 'aac':
          contentType = 'audio/mp4';
          break;
        case 'mp3':
          contentType = 'audio/mpeg';
          break;
        case 'wav':
          contentType = 'audio/wav';
          break;
        case 'ogg':
          contentType = 'audio/ogg';
          break;
        case 'flac':
          contentType = 'audio/flac';
          break;
        case 'webm':
          contentType = 'audio/webm';
          break;
        default:
          contentType = 'audio/mpeg';
      }

      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: filename,
          contentType: DioMediaType.parse(contentType),
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

  // ============================================
  // PHISHING DETECTION ENDPOINTS
  // ============================================

  /// Scan text for phishing
  Future<Map<String, dynamic>> scanTextForPhishing(
    String text, {
    String scanType = 'auto',
  }) async {
    try {
      final response = await _dio.post('/phishing/scan-text', data: {
        'text': text,
        'scanType': scanType,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Scan URL for phishing
  Future<Map<String, dynamic>> scanUrlForPhishing(String url) async {
    try {
      final response = await _dio.post('/phishing/scan-url', data: {
        'url': url,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Batch scan for phishing
  Future<Map<String, dynamic>> batchScanForPhishing(
    List<String> items, {
    String scanType = 'auto',
  }) async {
    try {
      final response = await _dio.post('/phishing/batch-scan', data: {
        'items': items,
        'scanType': scanType,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get phishing scan history
  Future<Map<String, dynamic>> getPhishingHistory({
    int page = 1,
    int limit = 20,
    bool? phishingOnly,
    String? threatLevel,
  }) async {
    try {
      final response = await _dio.get(
        '/phishing/history',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (phishingOnly != null) 'phishingOnly': phishingOnly,
          if (threatLevel != null) 'threatLevel': threatLevel,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get phishing scan by ID
  Future<Map<String, dynamic>> getPhishingHistoryById(String id) async {
    try {
      final response = await _dio.get('/phishing/history/$id');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete phishing scan from history
  Future<Map<String, dynamic>> deletePhishingHistory(String id) async {
    try {
      final response = await _dio.delete('/phishing/history/$id');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get phishing detection statistics
  Future<Map<String, dynamic>> getPhishingStatistics() async {
    try {
      final response = await _dio.get('/phishing/statistics');
      return response.data;
    } catch (e) {
      rethrow;
    }
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

