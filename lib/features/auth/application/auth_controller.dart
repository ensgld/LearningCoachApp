import 'package:learning_coach/features/auth/data/api_auth_repository.dart';
import 'package:learning_coach/features/auth/data/auth_repository.dart';
import 'package:learning_coach/features/auth/domain/auth_state.dart';
import 'package:learning_coach/features/auth/domain/auth_user.dart';
import 'package:learning_coach/shared/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// Auth Repository Provider
///
/// Provides the REAL API auth repository instance.
/// Uses ApiService from shared providers for backend communication.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final apiService = ref.read(apiServiceProvider);
  return ApiAuthRepository(apiService);
}

/// Auth Controller
///
/// Manages authentication state using AuthRepository.
/// Uses keepAlive to prevent state from being disposed during navigation.
///
/// State: AuthState (authenticated/unauthenticated/loading)
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);

    // Check for existing session on app init
    _checkSession();

    // Initially show loading state to prevent flash of login screen
    return const AuthStateLoading();
  }

  /// Check if user session exists (called on app init)
  Future<void> _checkSession() async {
    try {
      final user = await _repository.getCurrentUser();

      if (!ref.mounted) return;

      if (user != null) {
        state = AuthStateAuthenticated(user);
      } else {
        state = const AuthStateUnauthenticated();
      }
    } catch (e) {
      if (ref.mounted) {
        state = const AuthStateUnauthenticated();
      }
    }
  }

  /// Login with email and password
  ///
  /// Shows loading state during login.
  /// Updates state to authenticated on success.
  /// Returns error message on failure.
  Future<String?> login(String email, String password) async {
    state = const AuthStateLoading();

    try {
      final user = await _repository.login(email: email, password: password);

      if (!ref.mounted) return null;

      state = AuthStateAuthenticated(user);
      return null; // Success
    } on InvalidCredentialsException catch (e) {
      if (!ref.mounted) return null;
      state = const AuthStateUnauthenticated();
      return e.message;
    } catch (e) {
      if (!ref.mounted) return null;
      state = const AuthStateUnauthenticated();
      return 'Bir hata oluştu: $e';
    }
  }

  /// Signup with email, password, and display name
  ///
  /// Validates email uniqueness and password strength.
  /// Returns error message on failure.
  Future<String?> signup({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AuthStateLoading();

    try {
      final user = await _repository.signup(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (!ref.mounted) return null;

      state = AuthStateAuthenticated(user);
      return null; // Success
    } on EmailAlreadyExistsException catch (e) {
      if (!ref.mounted) return null;
      state = const AuthStateUnauthenticated();
      return e.message;
    } on WeakPasswordException catch (e) {
      if (!ref.mounted) return null;
      state = const AuthStateUnauthenticated();
      return e.message;
    } catch (e) {
      if (!ref.mounted) return null;
      state = const AuthStateUnauthenticated();
      return 'Bir hata oluştu: $e';
    }
  }

  /// Quick login as demo user (demo@demo.com / 123456)
  ///
  /// For testing and demonstration purposes.
  Future<void> loginAsDemo() async {
    state = const AuthStateLoading();

    try {
      final user = await _repository.loginAsDemo();

      if (!ref.mounted) return;

      state = AuthStateAuthenticated(user);
    } catch (e) {
      if (!ref.mounted) return;
      state = const AuthStateUnauthenticated();
    }
  }

  /// Login as guest
  ///
  /// Limited access without registration.
  Future<void> loginAsGuest() async {
    state = const AuthStateLoading();

    try {
      final user = await _repository.loginAsGuest();

      if (!ref.mounted) return;

      state = AuthStateAuthenticated(user);
    } catch (e) {
      if (!ref.mounted) return;
      state = const AuthStateUnauthenticated();
    }
  }

  /// Logout current user
  ///
  /// Clears authentication state.
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (e) {
      // Ignore logout errors
    }

    if (!ref.mounted) return;

    state = const AuthStateUnauthenticated();
  }

  /// Mock Google Login (for UI flow testing)
  Future<void> loginWithGoogle() async {
    state = const AuthStateLoading();

    // Simulate OAuth flow
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!ref.mounted) return;

    // For now, login as demo user
    await loginAsDemo();
  }

  /// Mock Apple Login (for UI flow testing)
  Future<void> loginWithApple() async {
    state = const AuthStateLoading();

    // Simulate OAuth flow
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!ref.mounted) return;

    // For now, login as demo user
    await loginAsDemo();
  }

  /// Mock Forgot Password
  ///
  /// Simulates sending password reset email.
  Future<String?> sendPasswordResetEmail(String email) async {
    // Simulate email sending
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Mock success
    return null;
  }

  /// Get current authenticated user
  ///
  /// Returns null if not authenticated.
  AuthUser? get currentUser {
    final currentState = state;
    if (currentState is AuthStateAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated => state is AuthStateAuthenticated;

  /// Check if authentication is in progress
  bool get isLoading => state is AuthStateLoading;
}
