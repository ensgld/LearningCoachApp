import 'package:equatable/equatable.dart';

/// Auth User Model
///
/// Represents an authenticated user in the system.
/// Used for both mock and real authentication.
class AuthUser extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final bool isGuest;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.isGuest = false,
  });

  /// Demo user for quick testing
  static const demo = AuthUser(
    id: 'demo-user-id',
    email: 'demo@demo.com',
    displayName: 'Demo User',
  );

  /// Guest user
  static const guest = AuthUser(
    id: 'guest-user-id',
    email: 'guest@app.com',
    displayName: 'Misafir',
    isGuest: true,
  );

  @override
  List<Object?> get props => [id, email, displayName, isGuest];

  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isGuest,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}
