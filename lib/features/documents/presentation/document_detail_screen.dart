import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/models.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBadge(
              context,
              document.status,
              locale,
              document.processingProgress,
            ),
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
    double progress,
  ) {
    final scheme = Theme.of(context).colorScheme;

    Color color;
    String label;
    IconData icon;

    switch (status) {
      case DocStatus.processing:
        color = Colors.orange;
        label =
            '${AppStrings.getDocStatusProcessing(locale)} %${(progress * 100).round()}';
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
        color: color.withValues(alpha: 0.12),
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Doküman Silinsin mi?'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await ref.read(apiDocumentRepositoryProvider).deleteDocument(document.id);
      ref.invalidate(documentsProvider);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }
}
