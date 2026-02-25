import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/shared/data/api_stats_repository.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoachChatScreen extends ConsumerStatefulWidget {
  final String? initialPrompt;

  const CoachChatScreen({super.key, this.initialPrompt});

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 1. Loading durumunu tutan değişken
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendInitialMessage(widget.initialPrompt!);
      });
    }
  }

  Future<void> _sendInitialMessage(String text) async {
    // Check if the last message is already this prompt (deduplication)
    final messages = ref.read(coachTipMessagesProvider);
    if (messages.isNotEmpty) {
      final lastUserMessage = messages.lastWhere(
        (m) => m.isUser,
        orElse: () =>
            CoachMessage(text: '', isUser: true, timestamp: DateTime(0)),
      );
      if (lastUserMessage.text == text) {
        // Already sent, just scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(coachTipMessagesProvider.notifier).sendMessage(text);
      // Scroll to bottom after delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 2. Fonksiyonu güncelle: async/await ve loading kontrolü
  Future<void> _handleSend() async {
    final text = _textController.text;

    // Eğer boşsa veya zaten yükleniyorsa işlem yapma
    if (text.trim().isEmpty || _isLoading) return;

    // Loading'i başlat ve klavyeyi kapatma (isteğe bağlı)
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(coachTipMessagesProvider.notifier).sendMessage(text);

      // Mesaj gittikten sonra text alanını temizle
      if (mounted) {
        _textController.clear();
      }

      // En aşağı kaydır
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint('Hata: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Günlük özeti AI'ya gönderir.
  /// widget.initialPrompt varsa onu kullanır;
  /// yoksa dünkü istatistikleri toplayarak prompt'u kendisi oluşturur.
  Future<void> _handleInfoSend() async {
    if (_isLoading) return;

    // Önce mevcut initialPrompt'u dene
    if (widget.initialPrompt != null &&
        widget.initialPrompt!.trim().isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(coachTipMessagesProvider.notifier)
            .sendMessage(widget.initialPrompt!);
        _scrollToBottom();
      } catch (e) {
        debugPrint('Bilgi Ver hatası: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }

    // initialPrompt yoksa kendimiz oluşturalım
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      const lastTipDateKey = 'last_coach_tip_date';
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month}-${now.day}';
      await prefs.setString(lastTipDateKey, todayStr);

      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayStr = yesterday.toIso8601String().split('T')[0];

      final dailyStatsList = await ref.read(dailyStatsProvider.future);
      final sessions = await ref
          .read(apiStudySessionRepositoryProvider)
          .getSessions();
      final goals = await ref.read(goalsProvider.future);
      final userStats = ref.read(userStatsProvider);

      final yesterdayStats = dailyStatsList.firstWhere(
        (s) => s.date == yesterdayStr,
        orElse: () => DailyStats(date: yesterdayStr, minutes: 0, sessions: 0),
      );

      final yesterdaySessions = sessions.where((s) {
        return s.startTime.year == yesterday.year &&
            s.startTime.month == yesterday.month &&
            s.startTime.day == yesterday.day;
      }).toList();

      final buffer = StringBuffer();
      buffer.writeln(
        'Merhaba Koç, benim "Learning Coach" asistanımsın. '
        'İşte dünkü ($yesterdayStr) durumum:',
      );
      buffer.writeln('\n👤 **Kullanıcı Profili:**');
      buffer.writeln(
        '- Seviye: ${userStats.level} (${userStats.stage.name.toUpperCase()})',
      );
      buffer.writeln(
        '- XP: ${userStats.xp} / ${userStats.xpRequiredForNextLevel}',
      );
      buffer.writeln('- Toplam Altın: ${userStats.gold}');
      buffer.writeln('\n📅 **Dünkü Özet:**');
      buffer.writeln('- Toplam Çalışma: ${yesterdayStats.minutes} dakika');
      buffer.writeln('- Oturum Sayısı: ${yesterdayStats.sessions}');

      if (yesterdaySessions.isNotEmpty) {
        buffer.writeln('\n📝 **Oturum Detayları:**');
        for (final session in yesterdaySessions) {
          final goal = goals.firstWhere(
            (g) => g.id == session.goalId,
            orElse: () => Goal(title: 'Bilinmeyen Hedef', description: ''),
          );
          final h = session.startTime.hour.toString().padLeft(2, '0');
          final m = session.startTime.minute.toString().padLeft(2, '0');
          buffer.write(
            '- **$h:$m** | ${goal.title} (${session.durationMinutes} dk)',
          );
          if (session.quizScore != null) {
            buffer.write(' | Quiz Başarısı: %${session.quizScore}');
          }
          if (session.actualDurationSeconds != null) {
            final actualMins = (session.actualDurationSeconds! / 60).round();
            if (actualMins >= session.durationMinutes) {
              buffer.write(
                ' | ⚡ Verimli (Hedef: ${session.durationMinutes}dk, Gerçekleşen: ${actualMins}dk)',
              );
            } else {
              buffer.write(
                ' | 🐢 Hedefin altında (Hedef: ${session.durationMinutes}dk, Gerçekleşen: ${actualMins}dk)',
              );
            }
          }
          buffer.writeln();
        }
      } else {
        buffer.writeln('\nDün detaylı bir çalışma kaydım yoktu.');
      }

      buffer.writeln(
        '\nLütfen bu verilere dayanarak bana özel, motive edici ve '
        'gelişim odaklı bir tavsiye ver. Eğer dün verimsiz geçtiyse '
        'nazikçe uyar, boşa geçtiyse teşvik et, iyiyse kutla. Tavsiyeler ver.',
      );

      if (!mounted) return;
      await ref
          .read(coachTipMessagesProvider.notifier)
          .sendMessage(buffer.toString());
      _scrollToBottom();
    } catch (e) {
      debugPrint('Bilgi Ver hatası: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(coachTipMessagesProvider);
    final scheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // iOS
        systemNavigationBarColor: scheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: Column(
          children: [
            // --- HEADER KISMI ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.of(context).padding.top + 16,
                16,
                16,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.coachChatTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                        ),
                        Text(
                          'AI öğrenme asistanı',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // --- CHAT LISTESI ---
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  scheme.primaryContainer.withValues(
                                    alpha: 0.3,
                                  ),
                                  scheme.secondaryContainer.withValues(
                                    alpha: 0.3,
                                  ),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Merhaba! Size nasıl yardımcı olabilirim?',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return _ChatBubble(message: msg);
                      },
                    ),
            ),

            // --- INPUT ALANI ---
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  top: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "Bilgi Ver" butonu — her zaman görünür
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleInfoSend,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          side: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6366F1),
                                ),
                              )
                            : const Icon(Icons.info_outline_rounded, size: 18),
                        label: const Text(
                          'Bilgi Ver',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Mesaj giriş satırı
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _textController,
                            onSubmitted: _isLoading
                                ? null
                                : (_) => _handleSend(),
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              hintText: AppStrings.askCoachHint,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isLoading
                                ? [Colors.grey.shade400, Colors.grey.shade500]
                                : [
                                    const Color(0xFF6366F1),
                                    const Color(0xFF8B5CF6),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_isLoading
                                          ? Colors.grey
                                          : const Color(0xFF6366F1))
                                      .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : _handleSend,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final CoachMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: isUser
                ? const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isUser ? null : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: isUser ? Radius.zero : const Radius.circular(20),
              bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            ),
            boxShadow: [
              BoxShadow(
                color: isUser
                    ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: isUser ? Colors.white : scheme.onSurface,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Eğer backend kaynak dönerse burası çalışır
        if (!isUser && message.sources != null && message.sources!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              // ... Sources UI kısmı (orijinal koddaki gibi) ...
            ),
          ),
      ],
    );
  }
}
