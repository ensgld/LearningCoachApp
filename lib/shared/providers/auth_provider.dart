import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../services/api_service.dart';

// API Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Auth state provider
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<Map<String, dynamic>?>>(
      (ref) {
        return AuthStateNotifier(ref.read(apiServiceProvider));
      },
    );

class AuthStateNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final ApiService _apiService;

  AuthStateNotifier(this._apiService) : super(const AsyncValue.loading()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (_apiService.isLoggedIn) {
      try {
        final profile = await _apiService.getProfile();
        state = AsyncValue.data(profile);
      } catch (e) {
        state = const AsyncValue.data(null);
      }
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final result = await _apiService.login(email: email, password: password);
      state = AsyncValue.data(result['user'] as Map<String, dynamic>?);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    state = const AsyncValue.loading();
    try {
      final result = await _apiService.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AsyncValue.data(result['user'] as Map<String, dynamic>?);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    state = const AsyncValue.data(null);
  }

  bool get isLoggedIn => state.value != null;
}
