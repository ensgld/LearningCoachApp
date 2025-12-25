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

  // "Beni hatırla" checkbox state (mock - şu an işlevsel değil)

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Login işlemi
  ///
  /// 1. Form validasyonu kontrol et
  /// 2. AuthController.login çağır (otomatik loading state yönetir)
  /// 3. Success → /home'a yönlendir (router guard otomatik yapacak)
  /// 4. Error → Snackbar göster
  Future<void> _handleLogin() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Login (controller içinde loading state yönetilir)
    final error = await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;

    // Error varsa göster
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
    // Success durumunda router guard otomatik /home'a yönlendirir
  }

  /// Demo kullanıcı ile hızlı giriş
  ///
  /// demo@demo.com / 123456 ile otomatik giriş yapar
  Future<void> _handleDemoLogin() async {
    await ref.read(authControllerProvider.notifier).loginAsDemo();
    // Router guard otomatik /home'a yönlendirir
  }

  /// Google ile giriş (mock)
  Future<void> _handleGoogleSignIn() async {
    await ref.read(authControllerProvider.notifier).loginWithGoogle();
  }

  /// Apple ile giriş (mock)
  Future<void> _handleAppleSignIn() async {
    await ref.read(authControllerProvider.notifier).loginWithApple();
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

                // Şifremi unuttum linki
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/auth/forgot'),
                    child: const Text('Şifremi unuttum'),
                  ),
                ),

                const SizedBox(height: 24),

                // Login butonu
                Consumer(
                  builder: (context, ref, _) {
                    final isLoading = ref
                        .watch(authControllerProvider.notifier)
                        .isLoading;
                    return AuthButton(
                      label: 'Giriş Yap',
                      onPressed: _handleLogin,
                      isLoading: isLoading,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Demo Login butonu
                OutlinedButton.icon(
                  onPressed: _handleDemoLogin,
                  icon: const Icon(Icons.rocket_launch_outlined),
                  label: const Text('Demo ile Giriş (demo@demo.com)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
                      onPressed: () => context.go('/auth/signup'),
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
