import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/widgets/document_upload_options.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  Timer? _poller;

  void _startPolling() {
    if (_poller != null) return;
    _poller = Timer.periodic(const Duration(seconds: 3), (_) {
      ref.invalidate(documentsProvider);
    });
  }

  void _stopPolling() {
    _poller?.cancel();
    _poller = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final docsAsync = ref.watch(documentsProvider);
    final scheme = Theme.of(context).colorScheme;

    final docs = docsAsync.asData?.value;
    final hasProcessing =
        docs?.any((doc) => doc.status == DocStatus.processing) ?? false;
    if (hasProcessing) {
      _startPolling();
    } else {
      _stopPolling();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getNavDocs(locale),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.8,
              ),
            ),
            Text(
              AppStrings.getManageMaterialsSubtitle(locale),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        toolbarHeight: 80,
        actions: const [SizedBox(width: 16)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDocumentUploadOptions(
          context: context,
          ref: ref,
          locale: locale,
        ),
        child: const Icon(Icons.add),
      ),
      body: docsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (docs) => docs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.primaryContainer.withValues(alpha: 0.3),
                            scheme.secondaryContainer.withValues(alpha: 0.3),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.getDocsEmptyState(locale),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return Dismissible(
                    key: Key(doc.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              'Silmek istediğinize emin misiniz?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('İptal'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  'Sil',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      ref
                          .read(apiDocumentRepositoryProvider)
                          .deleteDocument(doc.id)
                          .then((_) {
                            ref.invalidate(documentsProvider);
                          });
                    },
                    child: _DocumentCard(document: doc, locale: locale),
                  );
                },
              ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Document document;
  final String locale;

  const _DocumentCard({required this.document, required this.locale});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color statusColor;
    IconData statusIcon;
    Color gradientStart;
    Color gradientEnd;

    String statusLabel;
    final progressPercent = (document.processingProgress * 100).round();

    switch (document.status) {
      case DocStatus.ready:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
        gradientStart = const Color(0xFF10B981);
        gradientEnd = const Color(0xFF14B8A6);
        statusLabel = AppStrings.getDocStatusReady(locale);
        break;
      case DocStatus.processing:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.sync_rounded;
        gradientStart = const Color(0xFFF59E0B);
        gradientEnd = const Color(0xFFF97316);
        statusLabel =
            '${AppStrings.getDocStatusProcessing(locale)} %$progressPercent';
        break;
      case DocStatus.failed:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.error_rounded;
        gradientStart = const Color(0xFFEF4444);
        gradientEnd = const Color(0xFFF43F5E);
        statusLabel = AppStrings.getDocStatusFailed(locale);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/docs/detail', extra: document),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientStart.withValues(alpha: 0.2),
                        gradientEnd.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        statusLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'd MMM, HH:mm',
                            ).format(document.uploadedAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
