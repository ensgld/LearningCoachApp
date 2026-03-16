
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/data/quiz_repository.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:uuid/uuid.dart';

// ─── Quiz Settings Bottom Sheet ───────────────────────────────────────────────

Future<void> showQuizSettingsSheet(
  BuildContext context,
  Document document,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuizSettingsSheet(document: document),
  );
}

class _QuizSettingsSheet extends ConsumerStatefulWidget {
  final Document document;
  const _QuizSettingsSheet({required this.document});

  @override
  ConsumerState<_QuizSettingsSheet> createState() => _QuizSettingsSheetState();
}

class _QuizSettingsSheetState extends ConsumerState<_QuizSettingsSheet> {
  int _questionCount = 10;
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
    ('easy', 'Kolay', Icons.sentiment_satisfied_rounded, Color(0xFF10B981)),
    ('medium', 'Orta', Icons.sentiment_neutral_rounded, Color(0xFFF59E0B)),
    ('hard', 'Zor', Icons.sentiment_very_dissatisfied_rounded, Color(0xFFEF4444)),
  ];

  Future<void> _startQuiz() async {
    setState(() { _loading = true; _error = null; });

    final dummySessionId = const Uuid().v4();
    final session = QuizSession(
      id: dummySessionId,
      documentId: widget.document.id,
      documentTitle: widget.document.title,
      difficulty: _difficulty,
      questionCount: _questionCount,
      questions: const [],
      createdAt: DateTime.now(),
      isGenerating: true,
    );
    
    final apiRepo = ref.read(apiDocumentRepositoryProvider);
    final quizRepo = ref.read(quizRepositoryProvider.notifier);

    await quizRepo.addSession(session);

    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    apiRepo.generateQuiz(
      documentId: widget.document.id,
      count: _questionCount,
      difficulty: _difficulty,
      instructions: _promptController.text.trim().isEmpty ? null : _promptController.text.trim(),
    ).then((questions) {
      if (questions.isNotEmpty) {
         final updated = session.copyWith(
           questions: questions,
           questionCount: questions.length,
           isGenerating: false,
         );
         quizRepo.updateSession(updated);
         scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('✅ Test başarıyla oluşturuldu ve hazır!'), backgroundColor: Colors.green, duration: Duration(seconds: 4)),
         );
      } else {
         final updated = session.copyWith(isGenerating: false, questionCount: 0);
         quizRepo.updateSession(updated);
         scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('⚠️ Yeterli soru üretilemedi.'), backgroundColor: Colors.orange),
         );
      }
    }).catchError((e) {
        debugPrint('Quiz generation error: $e');
        final updated = session.copyWith(isGenerating: false, questionCount: 0);
        quizRepo.updateSession(updated);
        scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('❌ Test oluşturulurken bir hata oluştu.'), backgroundColor: Colors.red),
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
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Test Hazırla', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(widget.document.title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Soru Sayısı', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [('Daha az', 5), ('Standart', 10), ('Daha fazla', 20)].map((pair) {
                  final (label, n) = pair;
                  final sel = _questionCount == n;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _questionCount = n),
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
                            child: Text(
                              label,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: sel ? Colors.white : scheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
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
                  hintText: 'Örn: Sadece 3. bölümdeki kavramlara odaklan, zorlayıcı mantık soruları sor vs.',
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
                  onPressed: _loading ? null : _startQuiz,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _loading
                      ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Sorular Hazırlanıyor...', style: TextStyle(color: Colors.white)),
                        ])
                      : const Text('Testi Başlat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Quiz Screen ──────────────────────────────────────────────────────────────

class QuizScreen extends ConsumerStatefulWidget {
  final QuizSession session;

  const QuizScreen({super.key, required this.session});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;
  bool _showResult = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  final _letters = ['A', 'B', 'C', 'D'];

  QuizQuestion get _q => widget.session.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _selectOption(String letter) {
    if (_answered) return;
    setState(() {
      _selectedOption = letter;
      _answered = true;
      if (letter == _q.answer) _correctCount++;
    });
  }

  Future<void> _next() async {
    if (_currentIndex < widget.session.questions.length - 1) {
      await _animCtrl.reverse();
      setState(() { _currentIndex++; _selectedOption = null; _answered = false; });
      await _animCtrl.forward();
    } else {
      // Sonucu kaydet
      await ref.read(quizRepositoryProvider.notifier).recordAttempt(
        sessionId: widget.session.id,
        documentId: widget.session.documentId,
        correctCount: _correctCount,
        total: widget.session.questions.length,
      );
      setState(() => _showResult = true);
    }
  }

  Color _optColor(String letter) {
    if (!_answered) return Colors.transparent;
    if (letter == _q.answer) return const Color(0xFF10B981);
    if (letter == _selectedOption) return const Color(0xFFEF4444);
    return Colors.transparent;
  }

  Color _optBorder(String letter) {
    if (!_answered) return letter == _selectedOption ? const Color(0xFF6366F1) : Colors.grey.withValues(alpha: 0.3);
    return _optColor(letter);
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) return _buildResult(context);
    return _buildQuiz(context);
  }

  Widget _buildQuiz(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = widget.session.questions.length;

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
              value: _currentIndex / total,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Text(_q.question, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, height: 1.5)),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(_q.options.length, (i) {
                      final letter = _letters[i];
                      final text = _q.options[i];
                      final bg = _optColor(letter);
                      final border = _optBorder(letter);
                      final isCorrect = _answered && letter == _q.answer;
                      final isWrong = _answered && letter == _selectedOption && !isCorrect;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _selectOption(letter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: bg.withValues(alpha: _answered ? 0.12 : 0),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: border, width: _answered && (isCorrect || isWrong) ? 2 : 1.2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(color: bg.withValues(alpha: _answered ? 0.2 : 0.08), shape: BoxShape.circle, border: Border.all(color: border, width: 1.2)),
                                  child: Center(
                                    child: _answered && isCorrect
                                        ? Icon(Icons.check_rounded, size: 18, color: bg)
                                        : _answered && isWrong
                                            ? Icon(Icons.close_rounded, size: 18, color: bg)
                                            : Text(letter, style: TextStyle(fontWeight: FontWeight.bold, color: border)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(text, style: TextStyle(fontSize: 15, fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal, color: isCorrect ? const Color(0xFF10B981) : isWrong ? const Color(0xFFEF4444) : scheme.onSurface)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_answered) ...[
                      const SizedBox(height: 4),
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_rounded, color: Color(0xFF6366F1), size: 18),
                              const SizedBox(width: 10),
                              Expanded(child: Text(_q.explanation, style: TextStyle(color: scheme.onSurface, height: 1.5))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          child: Text(
                            _currentIndex < widget.session.questions.length - 1 ? 'Sonraki Soru →' : 'Sonuçları Gör',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final total = widget.session.questions.length;
    final percent = ((_correctCount / total) * 100).round();
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
                      Text('$_correctCount / $total', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: rc)),
                      const SizedBox(height: 8),
                      Text('$percent% Başarı', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(value: _correctCount / total, minHeight: 10, backgroundColor: rc.withValues(alpha: 0.15), valueColor: AlwaysStoppedAnimation<Color>(rc)),
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
                        onPressed: () => setState(() { _currentIndex = 0; _selectedOption = null; _answered = false; _correctCount = 0; _showResult = false; _animCtrl.forward(from: 0); }),
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

// ─── Quiz History Bottom Sheet ────────────────────────────────────────────────

void showQuizHistorySheet(BuildContext context, QuizSession session) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuizHistorySheet(session: session),
  );
}

class _QuizHistorySheet extends StatelessWidget {
  final QuizSession session;
  const _QuizHistorySheet({required this.session});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final attempts = session.attempts.reversed.toList();

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
                  const Icon(Icons.history_rounded, color: Color(0xFF6366F1)),
                  const SizedBox(width: 10),
                  Text('Deneme Geçmişi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Text('${session.difficultyLabel} · ${session.questionCount} Soru', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ),
            if (attempts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text('Henüz deneme yok', style: TextStyle(color: scheme.onSurfaceVariant)),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  itemCount: attempts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final a = attempts[i];
                    final rc = a.percent >= 80 ? const Color(0xFF10B981) : a.percent >= 60 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: rc.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14), border: Border.all(color: rc.withValues(alpha: 0.25))),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: rc.withValues(alpha: 0.15), shape: BoxShape.circle),
                            child: Center(child: Text('${attempts.length - i}', style: TextStyle(fontWeight: FontWeight.bold, color: rc, fontSize: 16))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${a.correctCount} doğru / ${a.total} soru · %${a.percent}', style: TextStyle(fontWeight: FontWeight.bold, color: rc)),
                                const SizedBox(height: 4),
                                Text('${a.date.day}.${a.date.month}.${a.date.year} ${a.date.hour}:${a.date.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              width: 48,
                              child: LinearProgressIndicator(value: a.score, minHeight: 8, backgroundColor: rc.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation<Color>(rc)),
                            ),
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
