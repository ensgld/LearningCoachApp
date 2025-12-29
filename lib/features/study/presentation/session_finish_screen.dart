import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/features/study/data/repositories/quiz_repository.dart';
import 'package:learning_coach/features/study/domain/models/quiz_model.dart';

class SessionFinishScreen extends ConsumerStatefulWidget {
  final String? topic;
  const SessionFinishScreen({super.key, this.topic});

  @override
  ConsumerState<SessionFinishScreen> createState() =>
      _SessionFinishScreenState();
}

class _SessionFinishScreenState extends ConsumerState<SessionFinishScreen> {
  final Map<String, int> _selectedAnswers = {}; // questionId -> selectedIndex

  @override
  Widget build(BuildContext context) {
    final quizAsyncValue = ref.watch(quizProvider(topic: widget.topic));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.quizTitle)),
      body: quizAsyncValue.when(
        data: (quiz) {
          if (quiz == null) {
            return _buildErrorState(context, 'Quiz bulunamadı.');
          }
          return _buildQuizContent(context, quiz);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorState(context, 'Hata: $err'),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/study/summary'),
            child: const Text('Özeti Gör'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, Quiz quiz) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(quiz.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '${quiz.totalQuestions} Soru',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          ...quiz.questions.map((q) => _buildMCQ(context, q)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _submitQuiz(quiz),
              child: const Text(AppStrings.quizSubmitBtn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMCQ(BuildContext context, Question question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soru ${question.position}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(question.text, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...List.generate(question.options.length, (index) {
              final option = question.options[index];
              return RadioListTile<int>(
                value: index,
                groupValue: _selectedAnswers[question.id],
                onChanged: (val) {
                  setState(() {
                    if (val != null) {
                      _selectedAnswers[question.id] = val;
                    }
                  });
                },
                title: Text(option),
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _submitQuiz(Quiz quiz) {
    // Calculate score
    int correctCount = 0;
    for (var q in quiz.questions) {
      if (_selectedAnswers[q.id] == q.correctIndex) {
        correctCount++;
      }
    }

    final score = (correctCount / quiz.questions.length) * 100;

    // Navigate to summary with results
    context.go(
      '/study/summary',
      extra: {
        'correctAnswers': correctCount,
        'totalQuestions': quiz.questions.length,
        'score': score.round(),
      },
    );
  }
}
