import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/shared/models/models.dart';

class DocumentDetailScreen extends StatelessWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBadge(context, document.status),
            const SizedBox(height: 24),
            Text('Özet', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                document.summary.isNotEmpty
                    ? document.summary
                    : 'Özet hazırlanıyor...',
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
                label: const Text(AppStrings.askDocHint),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, DocStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case DocStatus.processing:
        color = Colors.orange;
        label = AppStrings.docStatusProcessing;
        icon = Icons.sync;
        break;
      case DocStatus.ready:
        color = Colors.green;
        label = AppStrings.docStatusReady;
        icon = Icons.check_circle;
        break;
      case DocStatus.failed:
        color = Colors.red;
        label = AppStrings.docStatusFailed;
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
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
