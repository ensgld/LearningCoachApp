import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/features/auth/application/auth_controller.dart';
import 'package:learning_coach/features/auth/domain/auth_validators.dart';
import 'package:learning_coach/features/auth/presentation/widgets/auth_button.dart';
import 'package:learning_coach/features/auth/presentation/widgets/auth_text_field.dart';

/// Forgot Password Screen
///
/// Şifremi unuttum ekranı.
/// Email ile şifre sıfırlama linki gönderme (mock).
///
/// Mock implementasyon:
/// - Email validasyonu
/// - Snackbar ile  başarı mesajı
/// - Gerçekte: Backend'e email gönderilir ve reset linki mail'e gelir
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Email controller
  final _emailController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Şifre sıfırlama email'i gönder (mock)
  ///
  /// Gerçek implementasyon:
  /// 1. Backend'e email gönder
  /// 2. Backend şifre sıfırlama linki içeren email gönderir
  /// 3. Kullanıcı link'e tıklayarak şifresini sıfırlar
  Future<void> _handleSendResetEmail() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Loading başlat
    setState(() => _isLoading = true);

    try {
      // Mock: Email gönderildi simülasyonu
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(_emailController.text.trim());

      // Başarı mesajı
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Şifre sıfırlama linki ${_emailController.text} adresine gönderildi',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Email gönderildikten sonra geri dön
        // Gerçek uygulamada kullanıcı email'deki linke tıklar
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
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
      appBar: AppBar(title: const Text('Şifremi Unuttum')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Açıklama metni
                Text(
                  'Şifrenizi sıfırlamak için kayıtlı email adresinizi girin. '
                  'Size şifre sıfırlama linki göndereceğiz.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                // Email TextField
                AuthTextField(
                  label: 'Email',
                  hint: 'ornek@email.com',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: AuthValidators.emailValidator,
                  onSubmitted: (_) => _handleSendResetEmail(),
                ),

                const SizedBox(height: 24),

                // Gönder butonu
                AuthButton(
                  label: 'Sıfırlama Linki Gönder',
                  onPressed: _handleSendResetEmail,
                  isLoading: _isLoading,
                ),

                const Spacer(),

                // Bilgi metni (mock)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Not: Bu mock bir özellik. Gerçekte email hesabınıza '
                          'şifre sıfırlama linki gönderilir.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
