import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:intl/intl.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(documentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navDocs)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Mock file picker
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mock: Dosya Yüklendi...')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.docsUploadBtn),
      ),
      body: docs.isEmpty
          ? const Center(
              child: Text(
                AppStrings.docsEmptyState,
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = docs[index];
                return _DocumentCard(document: doc);
              },
            ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Document document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (document.status) {
      case DocStatus.ready:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case DocStatus.processing:
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        break;
      case DocStatus.failed:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description, color: Colors.blue),
        ),
        title: Text(document.title),
        subtitle: Text(DateFormat('d MMM, HH:mm').format(document.uploadedAt)),
        trailing: Icon(statusIcon, color: statusColor, size: 20),
        onTap: () => context.go('/docs/detail', extra: document),
      ),
    );
  }
}
