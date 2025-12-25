// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Auth Repository Provider
///
/// Provides the auth repository instance.
/// In production, this would return the real Firebase/API implementation.

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

/// Auth Repository Provider
///
/// Provides the auth repository instance.
/// In production, this would return the real Firebase/API implementation.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Auth Repository Provider
  ///
  /// Provides the auth repository instance.
  /// In production, this would return the real Firebase/API implementation.
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'dd2d5c56f899f86f1d0e24d22dc2f7ef4778dfba';

/// Auth Controller
///
/// Manages authentication state using AuthRepository.
/// Uses keepAlive to prevent state from being disposed during navigation.
///
/// State: AuthState (authenticated/unauthenticated/loading)

@ProviderFor(AuthController)
const authControllerProvider = AuthControllerProvider._();

/// Auth Controller
///
/// Manages authentication state using AuthRepository.
/// Uses keepAlive to prevent state from being disposed during navigation.
///
/// State: AuthState (authenticated/unauthenticated/loading)
final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AuthState> {
  /// Auth Controller
  ///
  /// Manages authentication state using AuthRepository.
  /// Uses keepAlive to prevent state from being disposed during navigation.
  ///
  /// State: AuthState (authenticated/unauthenticated/loading)
  const AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authControllerHash() => r'dd9fda4f13364ab057a5378dfc69041d72f65af5';

/// Auth Controller
///
/// Manages authentication state using AuthRepository.
/// Uses keepAlive to prevent state from being disposed during navigation.
///
/// State: AuthState (authenticated/unauthenticated/loading)

abstract class _$AuthController extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
