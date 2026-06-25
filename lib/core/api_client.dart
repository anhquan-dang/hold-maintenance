import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Safe in-memory fallback for platforms where secure storage might fail/not be supported (e.g. Web without config, etc.)
  final Map<String, String> _memoryFallback = {};

  ApiClient({String baseUrl = 'http://localhost:5056/api'})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await deleteToken();
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: 'jwt_token', value: token);
    } catch (_) {
      // Fallback
    }
    _memoryFallback['jwt_token'] = token;
  }

  Future<String?> readToken() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token != null) return token;
    } catch (_) {
      // Fallback
    }
    return _memoryFallback['jwt_token'];
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: 'jwt_token');
    } catch (_) {
      // Fallback
    }
    _memoryFallback.remove('jwt_token');
  }

  // Also support storing user profile info locally
  Future<void> saveUserJson(String jsonStr) async {
    try {
      await _storage.write(key: 'user_profile', value: jsonStr);
    } catch (_) {}
    _memoryFallback['user_profile'] = jsonStr;
  }

  Future<String?> readUserJson() async {
    try {
      final jsonStr = await _storage.read(key: 'user_profile');
      if (jsonStr != null) return jsonStr;
    } catch (_) {}
    return _memoryFallback['user_profile'];
  }

  Future<void> deleteUserJson() async {
    try {
      await _storage.delete(key: 'user_profile');
    } catch (_) {}
    _memoryFallback.remove('user_profile');
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
