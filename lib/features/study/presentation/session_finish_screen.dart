import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/features/study/application/study_controller.dart';
import 'package:learning_coach/shared/models/models.dart';

class SessionFinishScreen extends ConsumerWidget {
  const SessionFinishScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyState = ref.watch(studyControllerProvider);
    final questions = studyState?.questions ?? [];
    final selectedAnswers = studyState?.selectedAnswers ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.quizTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Öğrendiklerini Pekiştir',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            if (questions.isEmpty)
              const Center(child: Text('Soru bulunamadı.'))
            else
              ...questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildMCQ(
                    context,
                    ref,
                    index + 1,
                    question,
                    selectedAnswers[question.id],
                  ),
                );
              }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref.read(studyControllerProvider.notifier).calculateScore();
                  context.go('/study/summary');
                },
                child: const Text(AppStrings.quizSubmitBtn),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMCQ(
    BuildContext context,
    WidgetRef ref,
    int index,
    QuizQuestion question,
    int? selectedIndex,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Soru $index', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(question.question, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...question.options.asMap().entries.map((optEntry) {
              final optIndex = optEntry.key;
              final optText = optEntry.value;
              final isSelected = selectedIndex == optIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    ref
                        .read(studyControllerProvider.notifier)
                        .selectAnswer(question.id, optIndex);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? scheme.primary : scheme.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? scheme.primaryContainer.withOpacity(0.3) : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            optText,
                            style: TextStyle(
                              color: isSelected ? scheme.onPrimaryContainer : null,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
