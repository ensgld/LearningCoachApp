import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/shared/models/models.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  void _showAddDocumentDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Doküman Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file_rounded),
              title: const Text('Dosya Yükle'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mock: Dosya seçici açılacak...'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Fotoğraf Çek'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mock: Kamera açılacak...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('URL Ekle'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mock: URL girişi açılacak...')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBadge(context, document.status, locale),
            const SizedBox(height: 24),
            Text(
              AppStrings.getSummaryTitle(locale),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Text(
                document.summary.isNotEmpty
                    ? document.summary
                    : AppStrings.getSummaryProcessing(locale),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: document.status == DocStatus.ready
                    ? () => context.go('/docs/chat', extra: document)
                    : null,
                icon: const Icon(Icons.chat),
                label: Text(AppStrings.getAskDocHint(locale)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    DocStatus status,
    String locale,
  ) {
    final scheme = Theme.of(context).colorScheme;

    Color color;
    String label;
    IconData icon;

    switch (status) {
      case DocStatus.processing:
        color = Colors.orange;
        label = AppStrings.getDocStatusProcessing(locale);
        icon = Icons.sync;
        break;
      case DocStatus.ready:
        color = Colors.green;
        label = AppStrings.getDocStatusReady(locale);
        icon = Icons.check_circle;
        break;
      case DocStatus.failed:
        color = Colors.red;
        label = AppStrings.getDocStatusFailed(locale);
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
