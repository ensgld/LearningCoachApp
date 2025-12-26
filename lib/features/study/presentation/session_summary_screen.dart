import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/features/study/application/study_controller.dart';

class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyState = ref.watch(studyControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    final actualSeconds = studyState?.actualDurationSeconds ?? 0;
    final minutes = actualSeconds ~/ 60;
    final seconds = actualSeconds % 60;
    final score = studyState?.quizScore ?? 0;
    
    final totalQuestions = studyState?.questions?.length ?? 0;
    final correctCount = (score * totalQuestions / 100).round();
    final incorrectCount = totalQuestions - correctCount;

    String timeText = minutes > 0 
        ? '$minutes dakikalık verimli bir çalışma tamamladın.'
        : '$seconds saniyelik bir çalışma tamamladın.';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                score >= 70 ? Icons.workspace_premium_rounded : Icons.check_circle_rounded, 
                size: 80, 
                color: score >= 70 ? Colors.amber : scheme.primary
              ),
              const SizedBox(height: 24),
              Text(
                score >= 70 ? 'Harika İş Çıkardın!' : 'Tebrikler!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                timeText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Quiz Sonucu: %$score',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStat(context, Icons.check_circle, Colors.green, '$correctCount Doğru'),
                        const SizedBox(width: 24),
                        _buildStat(context, Icons.cancel, Colors.red, '$incorrectCount Yanlış'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
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

  Widget _buildStat(BuildContext context, IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
