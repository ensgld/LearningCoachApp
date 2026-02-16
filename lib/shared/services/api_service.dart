import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late final Dio _dio;
  String? _accessToken;

  static String get baseUrlLLM {
    // 1. Önce .env dosyasında tanımlı mı diye bakıyoruz
    final envUrl = dotenv.env['LLM_BASE_URL'];
    final debugModeLLM = dotenv.env['DEBUG_MODE_LLM'];

    if (debugModeLLM == 'true') {
      return 'http://127.0.0.1:8000';
    }

    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    // 2. Eğer .env boşsa veya okunamazsa, sabit IP
    return 'http://172.24.0.198:8000';
  }

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrlLLM,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // Expose Dio for other services
  Dio get dio => _dio;

  bool get isLoggedIn => _accessToken != null;

  /// Load token from storage (called by providers/repo)
  Future<void> loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('auth_token');
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _saveToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // --- Auth Methods ---

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data!;

    // Save token if present
    if (data['access_token'] != null) {
      await _saveToken(data['access_token'] as String);
    } else if (data['token'] != null) {
      await _saveToken(data['token'] as String);
    }

    return data;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'email': email, 'password': password, 'displayName': displayName},
    );

    final data = response.data!;

    // Save token if present
    if (data['access_token'] != null) {
      await _saveToken(data['access_token'] as String);
    } else if (data['token'] != null) {
      await _saveToken(data['token'] as String);
    }

    return data;
  }

  Future<void> logout() async {
    await _clearToken();
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return response.data!;
  }

  // --- LLM Chat Methods ---

  Future<Map<String, dynamic>> sendChatMessage(
    String message, {
    String? threadId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/chat',
      data: {'message': message, if (threadId != null) 'threadId': threadId},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getChatHistory({String? threadId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/chat/history',
      queryParameters: threadId != null ? {'threadId': threadId} : null,
    );
    return response.data!;
  }
}
