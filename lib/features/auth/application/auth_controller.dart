import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// Mock Auth Controller
///
/// Bu controller gerçek bir backend kullanmaz.
/// Sadece UI akışını test etmek için mock state yönetimi sağlar.
///
/// State: bool (isLoggedIn)
/// - false: Kullanıcı giriş yapmamış
/// - true: Kullanıcı giriş yapmış
@riverpod
class AuthController extends _$AuthController {
  @override
  bool build() {
    // Başlangıçta kullanıcı giriş yapmamış
    return false;
  }

  /// Mock Login
  ///
  /// Gerçek bir API çağrısı simüle eder (800ms delay).
  /// Email ve şifre validasyonu UI tarafında yapılır.
  ///
  /// Başarılı olursa state = true olur ve kullanıcı home'a yönlendirilir.
  Future<void> login(String email, String password) async {
    // API çağrısını simüle et
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Provider dispose edildiyse state'i güncelleme
    if (!ref.mounted) return;

    // Mock success - gerçekte backend'den response gelir
    state = true;
  }

  /// Mock Signup
  ///
  /// Yeni kullanıcı kaydı simülasyonu.
  /// Gerçekte backend'e POST request gönderilir.
  Future<void> signup({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // API çağrısı simülasyonu
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Provider dispose edildiyse state'i güncelleme
    if (!ref.mounted) return;

    // Mock success
    state = true;
  }

  /// Logout
  ///
  /// Kullanıcıyı çıkış yapar.
  /// Gerçekte token'ları temizler, secure storage'ı sıfırlar.
  void logout() {
    state = false;
  }

  /// Guest Login
  ///
  /// Misafir olarak giriş yap.
  /// State'i true yapar, route guard'dan geçer.
  /// Gerçekte limited access ile kullanıcı yaratılabilir.
  void guestLogin() {
    state = true;
  }

  /// Mock Google Login
  ///
  /// Google OAuth simülasyonu.
  /// Gerçekte google_sign_in paketi kullanılır.
  Future<void> loginWithGoogle() async {
    // OAuth redirect simülasyonu
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Provider dispose edildiyse state'i güncelleme
    if (!ref.mounted) return;

    // Mock success
    state = true;
  }

  /// Mock Apple Login
  ///
  /// Apple Sign In simülasyonu.
  /// Gerçekte sign_in_with_apple paketi kullanılır.
  /// Sadece iOS platformunda çalışır.
  Future<void> loginWithApple() async {
    // Apple OAuth simülasyonu
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Provider dispose edildiyse state'i güncelleme
    if (!ref.mounted) return;

    // Mock success
    state = true;
  }

  /// Mock Forgot Password
  ///
  /// Şifre sıfırlama email'i gönderme simülasyonu.
  /// Gerçekte backend'e email gönderilir.
  Future<void> sendPasswordResetEmail(String email) async {
    // Email gönderme simülasyonu
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Mock success - gerçekte success/error response gelir
  }
}
