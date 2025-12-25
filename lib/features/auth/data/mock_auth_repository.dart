import 'package:learning_coach/features/auth/data/auth_repository.dart';
import 'package:learning_coach/features/auth/domain/auth_user.dart';

/// Mock Auth Repository
///
/// In-memory implementation of AuthRepository for development/testing.
/// Stores users in a Map and simulates async operations.
///
/// Pre-registered users:
/// - demo@demo.com / 123456 (Demo User)
class MockAuthRepository implements AuthRepository {
  // In-memory user storage (email -> user data)
  final Map<String, _MockUserData> _users = {
    'demo@demo.com': _MockUserData(user: AuthUser.demo, password: '123456'),
  };

  // Current logged-in user
  AuthUser? _currentUser;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Check if user exists
    final userData = _users[email.toLowerCase()];
    if (userData == null || userData.password != password) {
      throw const InvalidCredentialsException();
    }

    // Set current user
    _currentUser = userData.user;
    return userData.user;
  }

  @override
  Future<AuthUser> signup({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Validate password
    if (password.length < 6) {
      throw const WeakPasswordException();
    }

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Check if email already exists
    if (_users.containsKey(email.toLowerCase())) {
      throw const EmailAlreadyExistsException();
    }

    // Create new user
    final newUser = AuthUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email.toLowerCase(),
      displayName: displayName ?? email.split('@').first,
    );

    // Store user
    _users[email.toLowerCase()] = _MockUserData(
      user: newUser,
      password: password,
    );

    // Set current user
    _currentUser = newUser;
    return newUser;
  }

  @override
  Future<AuthUser> loginAsGuest() async {
    // Simulate delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    _currentUser = AuthUser.guest;
    return AuthUser.guest;
  }

  @override
  Future<AuthUser> loginAsDemo() async {
    // Simulate delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    _currentUser = AuthUser.demo;
    return AuthUser.demo;
  }

  @override
  Future<void> logout() async {
    // Simulate delay
    await Future<void>.delayed(const Duration(milliseconds: 200));

    _currentUser = null;
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    // In a real app, this would check secure storage for a session token
    // For now, just return the in-memory current user
    return _currentUser;
  }
}

/// Internal class to store user data with password
class _MockUserData {
  final AuthUser user;
  final String password;

  _MockUserData({required this.user, required this.password});
}
