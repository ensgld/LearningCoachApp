import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: scheme.primary),
              const SizedBox(height: 24),
              Text(
                'Tebrikler!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                '45 dakikalık verimli bir çalışma tamamladın.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text('Quiz Skoru: %85'),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Ana Sayfaya Dön'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
