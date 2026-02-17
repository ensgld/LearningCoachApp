import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';

class SessionFinishScreen extends StatelessWidget {
  const SessionFinishScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildMCQ(context, 1, "Flutter'da 'State' neyi temsil eder?", [
              'Uygulamanın o anki durumu',
              "Bir widget'ın rengi",
              'Veritabanı bağlantısı',
            ]),
            const SizedBox(height: 24),
            _buildTextField(context, 2, 'State Management neden gereklidir?'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/study/summary'),
                child: const Text(AppStrings.quizSubmitBtn),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMCQ(
    BuildContext context,
    int index,
    String question,
    List<String> options,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Soru $index', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(question, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...options.map(
              (opt) => RadioListTile(
                value: opt,
                // ignore: deprecated_member_use
                groupValue: null,
                // ignore: deprecated_member_use
                onChanged: (value) {},
                title: Text(opt),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, int index, String question) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Soru $index', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(question, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(hintText: 'Cevabınızı yazın...'),
            ),
          ],
        ),
      ),
    );
  }
}
