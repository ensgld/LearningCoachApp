import 'package:learning_coach/features/auth/data/auth_repository.dart';
import 'package:learning_coach/features/auth/domain/auth_user.dart';
import 'package:learning_coach/shared/services/api_service.dart';

/// Real API-based Auth Repository
///
/// Connects to backend API for authentication operations.
class ApiAuthRepository implements AuthRepository {
  final ApiService _apiService;

  ApiAuthRepository(this._apiService);

  @override
  Future<AuthUser> signup({
    required String email,
    required String password,
    String? displayName,
  }) async {
    print('🔑 ApiAuthRepository.signup: $email');

    try {
      final response = await _apiService.register(
        email: email,
        password: password,
        displayName: displayName ?? 'User',
      );

      print('✅ Signup successful: ${response['user']}');

      final user = response['user'] as Map<String, dynamic>;
      return AuthUser(
        id: user['id'] as String,
        email: user['email'] as String,
        displayName: user['displayName'] as String? ?? 'User',
        isGuest: user['isGuest'] as bool? ?? false,
      );
    } on Exception catch (e) {
      print('❌ Signup failed: $e');

      // Handle specific errors
      if (e.toString().contains('409') || e.toString().contains('already')) {
        throw const EmailAlreadyExistsException('Bu email zaten kullanımda');
      }

      if (e.toString().contains('400') || e.toString().contains('validation')) {
        throw const WeakPasswordException('Şifre en az 8 karakter olmalı');
      }

      rethrow;
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    print('🔑 ApiAuthRepository.login: $email');

    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      print('✅ Login successful: ${response['user']}');

      final user = response['user'] as Map<String, dynamic>;
      return AuthUser(
        id: user['id'] as String,
        email: user['email'] as String,
        displayName: user['displayName'] as String? ?? 'User',
        isGuest: user['isGuest'] as bool? ?? false,
      );
    } catch (e) {
      print('❌ Login failed: $e');

      if (e.toString().contains('400') || e.toString().contains('401')) {
        throw const InvalidCredentialsException('Email veya şifre hatalı');
      }

      rethrow;
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    print('🔑 ApiAuthRepository.getCurrentUser');

    // Ensure token is loaded from storage
    await _apiService.loadToken();

    if (!_apiService.isLoggedIn) {
      print('📭 No active session');
      return null;
    }

    try {
      final user = await _apiService.getProfile();
      print('✅ Current user: ${user['email']}');

      return AuthUser(
        id: user['id'] as String,
        email: user['email'] as String,
        displayName: user['displayName'] as String? ?? 'User',
        isGuest: user['isGuest'] as bool? ?? false,
      );
    } catch (e) {
      print('❌ Get current user failed: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    print('🔑 ApiAuthRepository.logout');
    await _apiService.logout();
  }

  @override
  Future<AuthUser> loginAsDemo() async {
    print('🔑 ApiAuthRepository.loginAsDemo');
    return login(email: 'demo@learningcoach.com', password: 'password123');
  }

  @override
  Future<AuthUser> loginAsGuest() async {
    print('🔑 ApiAuthRepository.loginAsGuest');
    // Guest login would require backend support
    // For now, create a local guest user
    return const AuthUser(
      id: 'guest',
      email: 'guest@local',
      displayName: 'Guest User',
      isGuest: true,
    );
  }
}
