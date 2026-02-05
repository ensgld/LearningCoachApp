import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/features/auth/application/auth_controller.dart';
import 'package:learning_coach/features/auth/domain/auth_validators.dart';
import 'package:learning_coach/features/auth/presentation/widgets/auth_button.dart';
import 'package:learning_coach/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:learning_coach/features/auth/presentation/widgets/social_button.dart';

/// Signup Screen
///
/// Yeni kullanıcı kaydı ekranı.
/// Email, şifre ve şifre tekrarı ile kayıt olma + sosyal kayıt seçenekleri.
///
/// Features:
/// - İsim (opsiyonel)
/// - Email validasyonu
/// - Şifre validasyonu
/// - Şifre eşleşme kontrolü
/// - "Şartları kabul ediyorum" checkbox (required, mock)
/// - Loading state
/// - Google/Apple ile kayıt (mock)
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Text controller'lar
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _acceptTerms = false; // Şartları kabul et checkbox

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Signup işlemi
  ///
  /// 1. Form validasyonu
  /// 2. Şartları kabul kontrolü
  /// 3. Mock signup çağrısı
  /// 4. Success → /home
  Future<void> _handleSignup() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Şartları kabul kontrolü
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanım şartlarını kabul etmelisiniz')),
      );
      return;
    }

    // Loading başlat
    setState(() => _isLoading = true);

    try {
      // Mock signup
      await ref
          .read(authControllerProvider.notifier)
          .signup(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
          );

      // Success
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Google ile kayıt (mock)
  Future<void> _handleGoogleSignup() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).loginWithGoogle();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google ile kayıt: Yakında')),
        );
        context.go('/home');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Apple ile kayıt (mock)
  Future<void> _handleAppleSignup() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).loginWithApple();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple ile kayıt: Yakında')),
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
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // İsim (Zorunlu)
                AuthTextField(
                  label: 'Ad Soyad',
                  hint: 'Adınız ve Soyadınız',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ad Soyad girilmesi zorunludur';
                    }
                    if (value.trim().length < 2) {
                      return 'En az 2 karakter olmalı';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email
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

                // Şifre
                AuthTextField(
                  label: 'Şifre',
                  hint: 'En az 8 karakter',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  validator: AuthValidators.passwordValidator,
                ),

                const SizedBox(height: 16),

                // Şifre tekrar
                AuthTextField(
                  label: 'Şifre Tekrar',
                  hint: 'Şifrenizi tekrar girin',
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) => AuthValidators.confirmPasswordValidator(
                    value,
                    _passwordController.text,
                  ),
                  onSubmitted: (_) => _handleSignup(),
                ),

                const SizedBox(height: 16),

                // Şartları kabul et checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() => _acceptTerms = value ?? false);
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _acceptTerms = !_acceptTerms);
                        },
                        child: Row(
                          children: [
                            const Text('Kabul ediyorum: '),
                            TextButton(
                              onPressed: () {
                                // Mock: Şartlar sayfası
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Kullanım Şartları: Yakında'),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Kullanım Şartları'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Kayıt Ol butonu
                AuthButton(
                  label: 'Hesap Oluştur',
                  onPressed: _handleSignup,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                // Divider
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

                // Social butonlar
                SocialButton(
                  icon: Icons.g_mobiledata,
                  label: 'Google ile kayıt ol',
                  onPressed: _handleGoogleSignup,
                ),

                const SizedBox(height: 12),

                if (Platform.isIOS)
                  SocialButton(
                    icon: Icons.apple,
                    label: 'Apple ile kayıt ol',
                    onPressed: _handleAppleSignup,
                    backgroundColor: Colors.black,
                    iconColor: Colors.white,
                  ),

                const SizedBox(height: 24),

                // "Zaten hesabın var mı?"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Zaten hesabın var mı?'),
                    TextButton(
                      onPressed: () => context.go('/auth/login'),
                      child: const Text('Giriş yap'),
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
