import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Change based on your setup:
  // iOS Simulator: http://localhost:3000/api/v1
  // Android Emulator: http://10.0.2.2:3000/api/v1
  // Real device: http://YOUR_IP:3000/api/v1
  static String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api/v1';

  final Dio _dio;
  Dio get dio => _dio;
  String? _accessToken;
  String? _refreshToken;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ) {
    _setupInterceptors();
    _loadTokens();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('🌐 API REQUEST: ${options.method} ${options.uri}');
          print('📦 Data: ${options.data}');
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ API RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('❌ API ERROR: ${error.requestOptions.uri}');
          print('   Type: ${error.type}');
          print('   Message: ${error.message}');
          if (error.response != null) {
            print('   Status: ${error.response?.statusCode}');
            print('   Data: ${error.response?.data}');
          }

          if (error.response?.statusCode == 401 && _refreshToken != null) {
            // Token expired, try refresh
            if (await _refreshAccessToken()) {
              // Retry request with new token
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $_accessToken';
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadTokens() async {
    print('🔄 ApiService._loadTokens started');
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken == null) {
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      print('✅ ApiService._loadTokens loaded: $_accessToken');
    } else {
      print(
        '⚠️ ApiService._loadTokens: Token already set, skipping load (race condition avoided)',
      );
    }
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = null;
    _refreshToken = null;
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': _refreshToken},
      );

      _accessToken = response.data['accessToken'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _accessToken!);
      return true;
    } catch (e) {
      await _clearTokens();
      return false;
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password, 'displayName': displayName},
    );

    await _saveTokens(
      response.data['accessToken'] as String,
      response.data['refreshToken'] as String,
    );

    return response.data as Map<String, dynamic>;
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('🔄 ApiService.login called');
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      print('✅ ApiService.login response received');

      print('🔄 Saving tokens...');
      await _saveTokens(
        response.data['accessToken'] as String,
        response.data['refreshToken'] as String,
      );
      print('✅ Tokens saved');

      final Map<String, dynamic> result = response.data as Map<String, dynamic>;
      return result;
    } catch (e) {
      print('❌ ApiService.login error: $e');
      rethrow;
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    try {
      print('🔄 SharedPreferences.getInstance...');
      final prefs = await SharedPreferences.getInstance();
      print('✅ SharedPreferences instance got. Writing tokens...');
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      print('✅ _saveTokens complete');
    } catch (e) {
      print('❌ _saveTokens error: $e');
      rethrow;
    }
  }

  // Get Profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/auth/me');
    return response.data['user'] as Map<String, dynamic>;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await _clearTokens();
    }
  }

  bool get isLoggedIn => _accessToken != null;
}
