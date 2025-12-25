import 'package:learning_coach/features/auth/domain/auth_user.dart';

/// Auth Repository Interface
///
/// Abstract interface for authentication operations.
/// Allows swapping between mock and real implementations.
abstract class AuthRepository {
  /// Login with email and password
  ///
  /// Throws [InvalidCredentialsException] if credentials are invalid
  Future<AuthUser> login({required String email, required String password});

  /// Register new user
  ///
  /// Throws [EmailAlreadyExistsException] if email is already registered
  /// Throws [WeakPasswordException] if password is too weak
  Future<AuthUser> signup({
    required String email,
    required String password,
    String? displayName,
  });

  /// Login as guest
  Future<AuthUser> loginAsGuest();

  /// Login as demo user (for testing)
  Future<AuthUser> loginAsDemo();

  /// Logout current user
  Future<void> logout();

  /// Check if user session exists (for app init)
  Future<AuthUser?> getCurrentUser();
}

/// Exception: Invalid credentials
class InvalidCredentialsException implements Exception {
  final String message;
  const InvalidCredentialsException([this.message = 'Email veya şifre hatalı']);

  @override
  String toString() => message;
}

/// Exception: Email already exists
class EmailAlreadyExistsException implements Exception {
  final String message;
  const EmailAlreadyExistsException([this.message = 'Bu email zaten kayıtlı']);

  @override
  String toString() => message;
}

/// Exception: Weak password
class WeakPasswordException implements Exception {
  final String message;
  const WeakPasswordException([this.message = 'Şifre en az 6 karakter olmalı']);

  @override
  String toString() => message;
}
