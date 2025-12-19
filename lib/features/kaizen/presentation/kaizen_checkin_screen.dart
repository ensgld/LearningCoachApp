import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';

class KaizenCheckinScreen extends StatefulWidget {
  const KaizenCheckinScreen({super.key});

  @override
  State<KaizenCheckinScreen> createState() => _KaizenCheckinScreenState();
}

class _KaizenCheckinScreenState extends State<KaizenCheckinScreen> {
  final _didController = TextEditingController();
  final _blockedController = TextEditingController();
  final _todoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.quickKaizenTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Dün ne yaptım?', _didController),
            const SizedBox(height: 24),
            _buildSection('Beni ne engelledi?', _blockedController),
            const SizedBox(height: 24),
            _buildSection('Bugün neyi daha iyi yapacağım?', _todoController),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kaizen kaydedildi! Yarın için başarılar.'),
                    ),
                  );
                },
                child: const Text('Kaydet ve Bitir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Buraya yazın...'),
        ),
      ],
    );
  }
}
