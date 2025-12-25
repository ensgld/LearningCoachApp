import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/features/auth/application/auth_controller.dart';

/// Auth Welcome Screen
///
/// Uygulamanın ilk açılış ekranı.
/// Kullanıcıya giriş yapma, kayıt olma veya misafir devam etme seçenekleri sunar.
///
/// Akış:
/// - Giriş Yap → /auth/login
/// - Kayıt Ol → /auth/signup
/// - Misafir Devam Et → Direkt /home (auth state = true)
class AuthWelcomeScreen extends ConsumerWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Uygulama logosu/ikonu
              Icon(
                Icons.school,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 24),

              // Uygulama adı
              Text(
                'Learning Coach',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Slogan
              Text(
                'Öğrenme yolculuğunuzda yanınızdayız',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const Spacer(),

              // Primary: Giriş Yap butonu
              FilledButton(
                onPressed: () => context.go('/auth/login'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Giriş Yap',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 16),

              // Secondary: Kayıt Ol butonu
              OutlinedButton(
                onPressed: () => context.go('/auth/signup'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Kayıt Ol',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 16),

              // Text button: Misafir devam et
              /// Misafir olarak giriş - direkt uygulamaya erişim
              /// Auth state'i true yapar, route guard'dan geçer
              TextButton(
                onPressed: () {
                  // Misafir olarak giriş yap
                  ref.read(authControllerProvider.notifier).guestLogin();
                  // Route guard izin verir, /home'a git
                  context.go('/home');
                },
                child: const Text(
                  'Misafir Olarak Devam Et',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 32),

              // Gizlilik ve Şartlar (mock linkler)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // Mock: Gizlilik politikası
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gizlilik Politikası: Yakında'),
                        ),
                      );
                    },
                    child: Text(
                      'Gizlilik',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  Text(
                    ' • ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Mock: Kullanım şartları
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kullanım Şartları: Yakında'),
                        ),
                      );
                    },
                    child: Text(
                      'Şartlar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
