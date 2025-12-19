// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mock Auth Controller
///
/// Bu controller gerçek bir backend kullanmaz.
/// Sadece UI akışını test etmek için mock state yönetimi sağlar.
///
/// State: bool (isLoggedIn)
/// - false: Kullanıcı giriş yapmamış
/// - true: Kullanıcı giriş yapmış

@ProviderFor(AuthController)
const authControllerProvider = AuthControllerProvider._();

/// Mock Auth Controller
///
/// Bu controller gerçek bir backend kullanmaz.
/// Sadece UI akışını test etmek için mock state yönetimi sağlar.
///
/// State: bool (isLoggedIn)
/// - false: Kullanıcı giriş yapmamış
/// - true: Kullanıcı giriş yapmış
final class AuthControllerProvider
    extends $NotifierProvider<AuthController, bool> {
  /// Mock Auth Controller
  ///
  /// Bu controller gerçek bir backend kullanmaz.
  /// Sadece UI akışını test etmek için mock state yönetimi sağlar.
  ///
  /// State: bool (isLoggedIn)
  /// - false: Kullanıcı giriş yapmamış
  /// - true: Kullanıcı giriş yapmış
  const AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authControllerHash() => r'edb4d3cddfff2b3168664261558d858a2821546c';

/// Mock Auth Controller
///
/// Bu controller gerçek bir backend kullanmaz.
/// Sadece UI akışını test etmek için mock state yönetimi sağlar.
///
/// State: bool (isLoggedIn)
/// - false: Kullanıcı giriş yapmamış
/// - true: Kullanıcı giriş yapmış

abstract class _$AuthController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
