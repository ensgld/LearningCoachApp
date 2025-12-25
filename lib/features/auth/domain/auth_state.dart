import 'package:equatable/equatable.dart';
import 'package:learning_coach/features/auth/domain/auth_user.dart';

/// Auth State
///
/// Sealed class representing the authentication state of the app.
/// Uses pattern matching for type-safe state handling.
sealed class AuthState extends Equatable {
  const AuthState();
}

/// User is authenticated
class AuthStateAuthenticated extends AuthState {
  final AuthUser user;

  const AuthStateAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();

  @override
  List<Object?> get props => [];
}

/// Authentication in progress (login, signup, etc.)
class AuthStateLoading extends AuthState {
  const AuthStateLoading();

  @override
  List<Object?> get props => [];
}
