import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/features/auth/application/auth_controller.dart';
import 'package:learning_coach/features/auth/domain/auth_validators.dart';
import 'package:learning_coach/features/auth/presentation/widgets/auth_button.dart';
import 'package:learning_coach/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:learning_coach/features/auth/presentation/widgets/social_button.dart';

/// Login Screen
///
/// Kullanıcı giriş ekranı.
/// Email ve şifre ile giriş yapma + Google/Apple ile sosyal giriş seçenekleri.
///
/// Features:
/// - Email/şifre validasyonu
/// - Şifre göster/gizle
/// - "Beni hatırla" checkbox (mock)
/// - "Şifremi unuttum" linki
/// - Google/Apple ile giriş (mock)
/// - Loading state
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Form key (validasyon için)
  final _formKey = GlobalKey<FormState>();

  // Text controller'lar
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // "Beni hatırla" checkbox state (mock - şu an işlevsel değil)
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Login işlemi
  ///
  /// 1. Form validasyonu kontrol et
  /// 2. Loading state başlat
  /// 3. Mock auth controller'dan login çağır
  /// 4. Success  → /home'a yönlendir
  /// 5. Error → Snackbar göster (şu an error yok, her zaman success)
  Future<void> _handleLogin() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Loading başlat
    setState(() => _isLoading = true);

    try {
      // Mock login (800ms delay)
      await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);

      // Success - home'a git
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // Error handling (mock'ta error olmaz ama gerçekte olabilir)
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      // Loading bitir
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Google ile giriş (mock)
  ///
  /// Gerçekte: google_sign_in paketi kullanılır
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).loginWithGoogle();

      if (mounted) {
        // Mock success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google ile giriş: Yakında')),
        );
        context.go('/home');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Apple ile giriş (mock)
  ///
  /// Gerçekte: sign_in_with_apple paketi kullanılır
  /// Sadece iOS platformunda çalışır
  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).loginWithApple();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple ile giriş: Yakında')),
        );
        context.go('/home');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Email TextField
                AuthTextField(
                  label: 'Email',
                  hint: 'ornek@email.com',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: AuthValidators.emailValidator,
                ),

                const SizedBox(height: 16),

                // Password TextField
                AuthTextField(
                  label: 'Şifre',
                  hint: 'En az 8 karakter',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: AuthValidators.passwordValidator,
                  onSubmitted: (_) => _handleLogin(),
                ),

                const SizedBox(height: 8),

                // Row: "Beni hatırla" + "Şifremi unuttum"
                Row(
                  children: [
                    // Beni hatırla checkbox (mock - şu an işlevsiz)
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                    ),
                    const Text('Beni hatırla'),

                    const Spacer(),

                    // Şifremi unuttum linki
                    TextButton(
                      onPressed: () => context.push('/auth/forgot'),
                      child: const Text('Şifremi unuttum'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Login butonu
                AuthButton(
                  label: 'Giriş Yap',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                // Divider: "veya"
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'veya',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Google ile giriş
                SocialButton(
                  icon: Icons.g_mobiledata, // Google icon placeholder
                  label: 'Google ile devam et',
                  onPressed: _handleGoogleSignIn,
                ),

                const SizedBox(height: 12),

                // Apple ile giriş (sadece iOS'ta göster)
                if (Platform.isIOS)
                  SocialButton(
                    icon: Icons.apple,
                    label: 'Apple ile devam et',
                    onPressed: _handleAppleSignIn,
                    backgroundColor: Colors.black,
                    iconColor: Colors.white,
                  ),

                const SizedBox(height: 24),

                // "Hesabın yok mu? Kayıt ol"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Hesabın yok mu?'),
                    TextButton(
                      onPressed: () => context.pushReplacement('/auth/signup'),
                      child: const Text('Kayıt ol'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
