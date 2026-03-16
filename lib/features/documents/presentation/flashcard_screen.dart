import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/shared/data/flashcard_repository.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:uuid/uuid.dart';

// ─── Show Flashcard Settings Sheet ───────────────────────────────────────────

Future<void> showFlashcardSettingsSheet(
  BuildContext context,
  Document document,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FlashcardSettingsSheet(document: document),
  );
}

class _FlashcardSettingsSheet extends ConsumerStatefulWidget {
  final Document document;
  const _FlashcardSettingsSheet({required this.document});

  @override
  ConsumerState<_FlashcardSettingsSheet> createState() => _FlashcardSettingsSheetState();
}

class _FlashcardSettingsSheetState extends ConsumerState<_FlashcardSettingsSheet> {
  int _cardCount = 15;
  String _difficulty = 'medium';
  bool _loading = false;
  String? _error;
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  static const _difficulties = [
    ('easy',   'Kolay', Icons.sentiment_satisfied_rounded,       Color(0xFF10B981)),
    ('medium', 'Orta',  Icons.sentiment_neutral_rounded,         Color(0xFFF59E0B)),
    ('hard',   'Zor',   Icons.sentiment_very_dissatisfied_rounded, Color(0xFFEF4444)),
  ];

  Future<void> _createCards() async {
    setState(() { _loading = true; _error = null; });
    
    final dummySetId = const Uuid().v4();
    final set = FlashcardSet(
      id: dummySetId,
      documentId: widget.document.id,
      documentTitle: widget.document.title,
      difficulty: _difficulty,
      cardCount: _cardCount,
      cards: const [],
      createdAt: DateTime.now(),
      isGenerating: true,
    );
    
    final apiRepo = ref.read(apiDocumentRepositoryProvider);
    final flashcardRepo = ref.read(flashcardRepositoryProvider.notifier);

    await flashcardRepo.addSet(set);

    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    // Start generation in background using the cached providers
    apiRepo.generateFlashcards(
      documentId: widget.document.id,
      count: _cardCount,
      difficulty: _difficulty,
      instructions: _promptController.text.trim().isEmpty ? null : _promptController.text.trim(),
    ).then((cards) {
      if (cards.isNotEmpty) {
         final updated = set.copyWith(
           cards: cards,
           cardCount: cards.length,
           isGenerating: false,
         );
         flashcardRepo.updateSet(updated);
         scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('✅ Flash kartlar başarıyla oluşturuldu ve hazır!'), backgroundColor: Colors.green, duration: Duration(seconds: 4)),
         );
      } else {
         final updated = set.copyWith(isGenerating: false, cardCount: 0);
         flashcardRepo.updateSet(updated);
         scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('⚠️ Yeterli kart üretilemedi.'), backgroundColor: Colors.orange),
         );
      }
    }).catchError((e) {
        debugPrint('Flashcard generation error: $e');
        final updated = set.copyWith(isGenerating: false, cardCount: 0);
        flashcardRepo.updateSet(updated);
        scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('❌ Flash kart oluşturulurken bir hata oluştu.'), backgroundColor: Colors.red),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 80),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.style_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Flash Kart Oluştur', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(widget.document.title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Kart sayısı
              Text('Kart Sayısı', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [('Daha az', 10), ('Standart', 15), ('Daha fazla', 20)].map((pair) {
                  final (label, n) = pair;
                  final sel = _cardCount == n;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _cardCount = n),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: sel ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]) : null,
                            color: sel ? null : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: sel ? Colors.transparent : scheme.outlineVariant),
                          ),
                          child: Center(
                            child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: sel ? Colors.white : scheme.onSurface)),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Zorluk
              Text('Zorluk', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Column(
                children: _difficulties.map((d) {
                  final (key, label, icon, color) = d;
                  final sel = _difficulty == key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _difficulty = key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: sel ? color.withValues(alpha: 0.1) : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: sel ? color : scheme.outlineVariant, width: sel ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: sel ? color : scheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Text(label, style: TextStyle(fontWeight: sel ? FontWeight.bold : FontWeight.normal, color: sel ? color : scheme.onSurface)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // AI Prompt (Opsiyonel)
              Text('Özel Talimat (İsteğe Bağlı)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _promptController,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Örn: Sadece 3. bölümdeki kavramlara odaklan, biyoloji terimleriyle açıkla vs.',
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: const Color(0xFF6366F1), width: 2),
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 56,
                child: FilledButton(
                  onPressed: _loading ? null : _createCards,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _loading
                      ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Kartlar Oluşturuluyor...', style: TextStyle(color: Colors.white)),
                        ])
                      : const Text('Kartları Oluştur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Flashcard Study Screen ───────────────────────────────────────────────────

class FlashcardStudyScreen extends StatefulWidget {
  final FlashcardSet set;
  const FlashcardStudyScreen({super.key, required this.set});

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _flipped = false;
  int _knownCount = 0;
  bool _showResult = false;

  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  FlashCard get _card => widget.set.cards[_currentIndex];

  Future<void> _flip() async {
    if (!_flipped) {
      await _flipCtrl.forward();
    } else {
      await _flipCtrl.reverse();
    }
    setState(() => _flipped = !_flipped);
  }

  void _next({required bool known}) {
    if (known) _knownCount++;
    if (_currentIndex < widget.set.cards.length - 1) {
      setState(() {
        _currentIndex++;
        _flipped = false;
      });
      _flipCtrl.reset();
    } else {
      setState(() => _showResult = true);
    }
  }

  Color get _diffColor {
    switch (widget.set.difficulty) {
      case 'easy': return const Color(0xFF10B981);
      case 'hard': return const Color(0xFFEF4444);
      default:     return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) return _buildResult(context);
    return _buildStudy(context);
  }

  Widget _buildStudy(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = widget.set.cards.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / $total', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LinearProgressIndicator(
              value: total > 0 ? _currentIndex / total : 0,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Karta dokunarak çevir', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _diffColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(widget.set.difficultyLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _diffColor)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedBuilder(
                  animation: _flipAnim,
                  builder: (context, child) {
                    final angle = _flipAnim.value * math.pi;
                    final isBack = angle > (math.pi / 2);
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: isBack
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _buildCardFace(context, isBack: true),
                            )
                          : _buildCardFace(context, isBack: false),
                    );
                  },
                ),
              ),
            ),
          ),
          if (_flipped) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _next(known: false),
                      icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444)),
                      label: const Text('Bilmiyorum', style: TextStyle(color: Color(0xFFEF4444))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _next(known: true),
                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                      label: const Text('Biliyorum', style: TextStyle(color: Colors.white)),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton(
                  onPressed: _flip,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Cevabı Göster', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardFace(BuildContext context, {required bool isBack}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isBack
            ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isBack ? const Color(0xFF10B981) : const Color(0xFF6366F1)).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: Text(
                isBack ? 'ARKA YÜZ' : 'ÖN YÜZ',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isBack ? _card.back : _card.front,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (isBack) ...[
              const SizedBox(height: 24),
              const Text('Yukarı veya aşağı kaydır ↕', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final total = widget.set.cards.length;
    final percent = total > 0 ? ((_knownCount / total) * 100).round() : 0;
    final scheme = Theme.of(context).colorScheme;

    Color rc; String emoji; String txt;
    if (percent >= 80) { rc = const Color(0xFF10B981); emoji = '🎉'; txt = 'Harika!'; }
    else if (percent >= 60) { rc = const Color(0xFFF59E0B); emoji = '👍'; txt = 'İyi İş!'; }
    else { rc = const Color(0xFFEF4444); emoji = '📚'; txt = 'Tekrar Çalış'; }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                Text(txt, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: rc)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8))]),
                  child: Column(
                    children: [
                      Text('$_knownCount / $total', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: rc)),
                      const SizedBox(height: 8),
                      Text('$percent% bilindi', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(value: total > 0 ? _knownCount / total : 0, minHeight: 10, backgroundColor: rc.withValues(alpha: 0.15), valueColor: AlwaysStoppedAnimation<Color>(rc)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: const Text('Geri Dön'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => setState(() {
                          _currentIndex = 0; _flipped = false; _knownCount = 0; _showResult = false;
                          _flipCtrl.reset();
                        }),
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6366F1), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: const Text('Tekrar', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Flashcard History Sheet ─────────────────────────────────────────────────

void showFlashcardHistorySheet(BuildContext context, FlashcardSet set) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FlashcardHistorySheet(set: set),
  );
}

class _FlashcardHistorySheet extends StatelessWidget {
  final FlashcardSet set;
  const _FlashcardHistorySheet({required this.set});

  Color get _diffColor {
    switch (set.difficulty) {
      case 'easy': return const Color(0xFF10B981);
      case 'hard':  return const Color(0xFFEF4444);
      default:      return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 120),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.style_rounded, color: Color(0xFF6366F1)),
                  const SizedBox(width: 10),
                  Text('Flash Kart Detayı', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: _diffColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(set.difficultyLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _diffColor)),
                  ),
                  const SizedBox(width: 8),
                  Text('· ${set.cardCount} kart', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: set.cards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final card = set.cards[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('ÖN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(card.front, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('ARKA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(card.back, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant))),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
