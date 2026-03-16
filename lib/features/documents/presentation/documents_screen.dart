import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/models.dart';


class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  Timer? _poller;

  void _startPolling() {
    if (_poller != null) return;
    // 500ms — embedding request'leri aralarında bile yakalayabilmek için
    _poller = Timer.periodic(const Duration(milliseconds: 500), (_) {
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
      floatingActionButton: null,
      body: docsAsync.when(
        skipLoadingOnRefresh: true,
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

// ─── Document Card (Stateful — yerel animasyonlu progress için) ───────────────
class _DocumentCard extends StatefulWidget {
  final Document document;
  final String locale;

  const _DocumentCard({required this.document, required this.locale});

  @override
  State<_DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<_DocumentCard> {
  // Yerel sahte ilerleme: DB değerinden düşükse yavaşça artar,
  // DB değeri gelince ona snap eder (geriye gidemez).
  double _localProgress = 0.0;
  Timer? _fakeTimer;

  @override
  void initState() {
    super.initState();
    if (widget.document.status == DocStatus.processing) {
      _localProgress = widget.document.processingProgress;
      _startFakeTimer();
    }
  }

  @override
  void didUpdateWidget(_DocumentCard old) {
    super.didUpdateWidget(old);
    final real = widget.document.processingProgress;
    // Gerçek değer geldiyse her zaman ona geç (geriye gitme)
    if (real > _localProgress) {
      setState(() => _localProgress = real);
    }
    if (widget.document.status == DocStatus.processing) {
      _startFakeTimer();
    } else {
      _stopFakeTimer();
    }
  }

  void _startFakeTimer() {
    if (_fakeTimer != null) return;
    // Hız: totalChunks'a orantılı — büyük belge yavaş, küçük belge hızlı
    // Her tick 200ms → saniyede 5 tick
    // Hedef: embedding fazı (~%5→%90) totalChunks / batchSize * 2sn'de geçilsin
    final chunks = widget.document.totalChunks;
    double incrementPerTick;
    if (chunks <= 0) {
      incrementPerTick = 0.008; // bilinmiyorsa orta hız
    } else {
      final batchCount = (chunks / 10).ceil(); // batch başına ~2s (local Ollama)
      final estimatedSeconds = batchCount * 2.0;
      // %5'ten %90'a = 0.85 mesafe, estimatedSeconds * 5 tick
      incrementPerTick = (0.85 / (estimatedSeconds * 5)).clamp(0.0005, 0.01);
    }

    _fakeTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      final real = widget.document.processingProgress;
      // Gerçek değer varsa onu al (geriye gitme)
      final base = real > _localProgress ? real : _localProgress;
      // %99'a kadar hiç durmadan ilerle (summary aşaması dahil)
      if (base < 0.99) {
        setState(() => _localProgress = (base + incrementPerTick).clamp(0, 0.99));
      }
    });
  }

  void _stopFakeTimer() {
    _fakeTimer?.cancel();
    _fakeTimer = null;
  }

  @override
  void dispose() {
    _stopFakeTimer();
    super.dispose();
  }

  String _stepLabel(double progress) {
    // Gerçek DB değerini kullan (fazı doğru yansıtmak için)
    final real = widget.document.processingProgress;
    if (real <= 0.02) return 'Hazırlanıyor...';
    if (real <= 0.06) return 'Metin okunuyor...';
    if (real < 0.92) return 'Analiz ediliyor...';
    return 'Tamamlanıyor...';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final doc = widget.document;
    final locale = widget.locale;

    Color statusColor;
    IconData statusIcon;
    Color gradientStart;
    Color gradientEnd;
    String statusLabel;

    final isProcessing = doc.status == DocStatus.processing;
    final displayProgress = isProcessing ? _localProgress : doc.processingProgress;
    final progressPercent = (displayProgress * 100).round().clamp(0, 99);

    switch (doc.status) {
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
        statusLabel = _stepLabel(displayProgress);
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
          onTap: isProcessing
              ? null
              : () => context.go('/docs/detail', extra: doc),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                            doc.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                statusLabel,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (isProcessing) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '%$progressPercent',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ],
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
                                DateFormat('d MMM, HH:mm').format(doc.uploadedAt),
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
                      child: isProcessing
                          ? _SpinningIcon(color: statusColor)
                          : Icon(statusIcon, color: statusColor, size: 24),
                    ),
                  ],
                ),
                if (isProcessing) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: _localProgress,
                        end: displayProgress,
                      ),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor:
                              gradientStart.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(gradientStart),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dönen ikon — processing durumunda
class _SpinningIcon extends StatefulWidget {
  final Color color;
  const _SpinningIcon({required this.color});

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Icon(Icons.sync_rounded, color: widget.color, size: 24),
    );
  }
}
