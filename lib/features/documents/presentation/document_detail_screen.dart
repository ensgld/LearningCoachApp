import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/features/documents/presentation/flashcard_screen.dart';
import 'package:learning_coach/features/documents/presentation/quiz_screen.dart';
import 'package:learning_coach/shared/data/flashcard_repository.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/data/quiz_repository.dart';
import 'package:learning_coach/shared/models/models.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final scheme = Theme.of(context).colorScheme;

    // quiz oturumlarını dinle (state değişince rebuild tetiklenir)
    ref.watch(quizRepositoryProvider);
    final sessions = ref
        .read(quizRepositoryProvider.notifier)
        .sessionsForDoc(document.id);

    // flash kart setlerini dinle
    ref.watch(flashcardRepositoryProvider);
    final flashcardSets = ref
        .read(flashcardRepositoryProvider.notifier)
        .setsForDoc(document.id);

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
            _buildStatusBadge(context, document.status, locale, document.processingProgress),
            const SizedBox(height: 24),

            // Özet
            Text(AppStrings.getSummaryTitle(locale), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Text(
                document.summary.isNotEmpty ? document.summary : AppStrings.getSummaryProcessing(locale),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),

            const SizedBox(height: 24),

            // Sohbet butonu
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: document.status == DocStatus.ready ? () => context.go('/docs/chat', extra: document) : null,
                icon: const Icon(Icons.chat),
                label: Text(AppStrings.getAskDocHint(locale)),
              ),
            ),
            const SizedBox(height: 12),

            // Test Hazırla butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: document.status == DocStatus.ready
                    ? () async {
                        await showQuizSettingsSheet(context, document);
                      }
                    : null,
                icon: const Icon(Icons.quiz_rounded),
                label: const Text('Test Hazırla'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6366F1),
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Flash Kart Oluştur butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: document.status == DocStatus.ready
                    ? () async {
                        await showFlashcardSettingsSheet(context, document);
                      }
                    : null,
                icon: const Icon(Icons.style_rounded),
                label: const Text('Flash Kart Oluştur'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  side: const BorderSide(color: Color(0xFF8B5CF6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            // Oluşturulan Testler
            if (sessions.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'Oluşturulan Testler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              for (final s in sessions) _QuizSessionCard(session: s),
            ],

            // Oluşturulan Flash Kart Setleri
            if (flashcardSets.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'Oluşturulan Flash Kartlar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              for (final s in flashcardSets) _FlashcardSetCard(set: s),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, DocStatus status, String locale, double progress) {
    final scheme = Theme.of(context).colorScheme;
    Color color; String label; IconData icon;
    switch (status) {
      case DocStatus.processing:
        color = Colors.orange;
        label = '${AppStrings.getDocStatusProcessing(locale)} %${(progress * 100).round()}';
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
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
        ],
      ),
    );
    if (shouldDelete != true) return;
    try {
      await ref.read(apiDocumentRepositoryProvider).deleteDocument(document.id);
      ref.invalidate(documentsProvider);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }
}

// ─── Quiz Session Card ────────────────────────────────────────────────────────

class _QuizSessionCard extends StatelessWidget {
  final QuizSession session;
  const _QuizSessionCard({required this.session});

  Color get _diffColor {
    switch (session.difficulty) {
      case 'easy': return const Color(0xFF10B981);
      case 'hard': return const Color(0xFFEF4444);
      default: return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (session.isGenerating) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Test Hazırlanıyor...', style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
                  const SizedBox(height: 4),
                  Text('${session.difficultyLabel} · ${session.questionCount} soru', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final bestAttempt = session.attempts.isEmpty
        ? null
        : session.attempts.reduce((a, b) => a.percent > b.percent ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          // Zorluk ikonu
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _diffColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                session.difficulty == 'easy' ? '😊' : session.difficulty == 'hard' ? '🔥' : '🎯',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Bilgi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: _diffColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text(session.difficultyLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _diffColor)),
                    ),
                    const SizedBox(width: 6),
                    Text('${session.questionCount} soru', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                if (bestAttempt != null)
                  Text(
                    'En iyi: %${bestAttempt.percent} · ${session.attempts.length} deneme',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  )
                else
                  Text('Henüz denenmedi', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              ],
            ),
          ),

          // Info butonu
          IconButton(
            icon: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: scheme.outlineVariant, width: 1.5)),
              child: const Icon(Icons.info_outline_rounded, size: 16),
            ),
            onPressed: session.attempts.isEmpty
                ? null
                : () => showQuizHistorySheet(context, session),
            tooltip: 'Denemeler',
          ),

          // Başlat butonu
          const SizedBox(width: 4),
          IconButton(
            icon: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => QuizScreen(session: session),
              ),
            ),
            tooltip: 'Başlat',
          ),
        ],
      ),
    );
  }
}

// ─── Flashcard Set Card ───────────────────────────────────────────────────────

class _FlashcardSetCard extends StatelessWidget {
  final FlashcardSet set;
  const _FlashcardSetCard({required this.set});

  Color get _diffColor {
    switch (set.difficulty) {
      case 'easy': return const Color(0xFF10B981);
      case 'hard': return const Color(0xFFEF4444);
      default:     return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (set.isGenerating) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kartlar Hazırlanıyor...', style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
                  const SizedBox(height: 4),
                  Text('${set.difficultyLabel} · ${set.cardCount} kart', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          // Zorluk ikonu
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _diffColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                set.difficulty == 'easy' ? '😊' : set.difficulty == 'hard' ? '🔥' : '🎯',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Bilgi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: _diffColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text(set.difficultyLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _diffColor)),
                    ),
                    const SizedBox(width: 6),
                    Text('${set.cardCount} kart', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${set.createdAt.day}.${set.createdAt.month}.${set.createdAt.year}',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // Kart listesi butonu
          IconButton(
            icon: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: scheme.outlineVariant, width: 1.5)),
              child: const Icon(Icons.list_rounded, size: 16),
            ),
            onPressed: () => showFlashcardHistorySheet(context, set),
            tooltip: 'Kartları Gör',
          ),

          // Çalış butonu
          const SizedBox(width: 4),
          IconButton(
            icon: Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => FlashcardStudyScreen(set: set)),
            ),
            tooltip: 'Hemen Çalış',
          ),
        ],
      ),
    );
  }
}
