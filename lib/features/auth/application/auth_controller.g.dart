// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Auth Repository Provider
///
/// Provides the REAL API auth repository instance.
/// Uses ApiService from shared providers for backend communication.

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

/// Auth Repository Provider
///
/// Provides the REAL API auth repository instance.
/// Uses ApiService from shared providers for backend communication.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Auth Repository Provider
  ///
  /// Provides the REAL API auth repository instance.
  /// Uses ApiService from shared providers for backend communication.
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

String _$authRepositoryHash() => r'af7e1e21f5256064de1996da7153c117944ecc07';

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

String _$authControllerHash() => r'111bd007c18039edcc0834ba88cece530325587a';

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
