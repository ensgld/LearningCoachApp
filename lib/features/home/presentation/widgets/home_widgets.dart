import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/shared/data/api_stats_repository.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Today Plan Card ---
class TodayPlanCard extends ConsumerStatefulWidget {
  const TodayPlanCard({super.key});

  @override
  ConsumerState<TodayPlanCard> createState() => _TodayPlanCardState();
}

class _TodayPlanCardState extends ConsumerState<TodayPlanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return AnimatedScale(
      scale: _isHovered ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF9333EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.4),
              blurRadius: 32,
              offset: const Offset(0, 16),
              spreadRadius: -8,
            ),
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 14),
                    Text(
                      AppStrings.getDailyQuest(locale),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  AppStrings.getTodayAdventure(locale),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(
                      0,
                      _isHovered ? -2 : 0,
                      0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/study'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6366F1),
                          elevation: _isHovered ? 8 : 0,
                          shadowColor: Colors.black.withValues(alpha: 0.2),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 28),
                        label: Text(
                          AppStrings.getStartMission(locale),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Quick Kaizen Card ---
class QuickKaizenCard extends ConsumerStatefulWidget {
  const QuickKaizenCard({super.key});

  @override
  ConsumerState<QuickKaizenCard> createState() => _QuickKaizenCardState();
}

class _QuickKaizenCardState extends ConsumerState<QuickKaizenCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFFEC4899),
                    const Color(0xFFF43F5E),
                    _pulseController.value * 0.3,
                  )!,
                  const Color(0xFFF43F5E),
                  Color.lerp(
                    const Color(0xFFF43F5E),
                    const Color(0xFFEC4899),
                    _pulseController.value * 0.3,
                  )!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/kaizen'),
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.getQuickTask(locale),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.getDailyProgressHint(locale),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.4,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Progress Summary Card ---
// --- Progress Summary Card ---
class ProgressSummaryCard extends ConsumerWidget {
  const ProgressSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final scheme = Theme.of(context).colorScheme;

    final progressAsync = ref.watch(userProgressProvider);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () => context.push('/home/stats-detail'),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                      spreadRadius: -8,
                    ),
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.trending_up_rounded,
                                  color: scheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                AppStrings.getAdventureLog(locale),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          progressAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, _) => const Text('--'),
                            data: (data) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  context,
                                  '${data['totalStudyMinutes']}',
                                  AppStrings.getTotalMinutes(locale),
                                  Icons.timer_rounded,
                                  scheme,
                                ),
                                _buildDivider(scheme),
                                _buildStatItem(
                                  context,
                                  '${data['completedSessions']}',
                                  AppStrings.getSessions(locale),
                                  Icons.event_note_rounded,
                                  scheme,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider(ColorScheme scheme) => Container(
    height: 50,
    width: 1.5,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          scheme.outlineVariant.withValues(alpha: 0.1),
          scheme.outlineVariant.withValues(alpha: 0.6),
          scheme.outlineVariant.withValues(alpha: 0.1),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    ColorScheme scheme,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary.withValues(alpha: 0.2),
                      scheme.secondary.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: scheme.primary, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Coach Tip Card ---
class CoachTipCard extends ConsumerStatefulWidget {
  const CoachTipCard({super.key});

  @override
  ConsumerState<CoachTipCard> createState() => _CoachTipCardState();
}

class _CoachTipCardState extends ConsumerState<CoachTipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // 0. Check "Once per day" rule
      final prefs = await SharedPreferences.getInstance();
      const lastTipDateKey = 'last_coach_tip_date';
      final lastDate = prefs.getString(lastTipDateKey);
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month}-${now.day}'; // YYYY-M-D format

      // If already sent today, just open chat without prompt
      if (lastDate == todayStr) {
        if (!mounted) return;
        await context.push('/home/coach-chat'); // No extra prompt
        return;
      }

      // 1. Fetch Data for YESTERDAY
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayStr = yesterday.toIso8601String().split('T')[0];

      final dailyStatsList = await ref.read(dailyStatsProvider.future);
      final sessions = await ref
          .read(apiStudySessionRepositoryProvider)
          .getSessions();
      final goals = await ref.read(goalsProvider.future);
      final userStats = ref.read(userStatsProvider);

      // 2. Filter & Aggregate (Yesterday's data)
      final yesterdayStats = dailyStatsList.firstWhere(
        (s) => s.date == yesterdayStr,
        orElse: () => DailyStats(date: yesterdayStr, minutes: 0, sessions: 0),
      );

      final yesterdaySessions = sessions.where((s) {
        final date = DateTime(
          s.startTime.year,
          s.startTime.month,
          s.startTime.day,
        );
        return date.year == yesterday.year &&
            date.month == yesterday.month &&
            date.day == yesterday.day;
      }).toList();

      // 3. Construct Detailed Prompt
      final buffer = StringBuffer();
      buffer.writeln(
        'Merhaba Koç, benim "Learning Coach" asistanımsın. İşte dünkü ($yesterdayStr) durumum:',
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

          final timeStr =
              "${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}";

          buffer.write('- **$timeStr** | ${goal.title}');
          buffer.write(' (${session.durationMinutes} dk)');

          if (session.quizScore != null) {
            buffer.write(' | Quiz Başarısı: %${session.quizScore}');
          }

          // Efficiency Check (if actual duration is tracked)
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
        '\nLütfen bu verilere dayanarak bana özel, motive edici ve gelişim odaklı bir tavsiye ver. Eğer dün verimsiz geçtiyse nazikçe uyar, boşa geçtiyse teşvik et, iyiyse kutla. Tavsiyeler ver.',
      );

      // Save "Today" as the last sent date (so we don't send again today)
      await prefs.setString(lastTipDateKey, todayStr);

      if (!mounted) return;

      // 4. Navigate to new specific route for Coach Tip
      await context.push('/home/coach-chat', extra: buffer.toString());
    } catch (e) {
      debugPrint('Error preparing coach tip: $e');
      if (mounted) {
        await context.push('/home/chat'); // Fallback to empty chat
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF10B981),
                  Color(0xFF14B8A6),
                  Color(0xFF06B6D4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: Offset(0, 12 + _floatAnimation.value),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoading ? null : _handleTap,
                    borderRadius: BorderRadius.circular(28),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1200),
                            builder: (context, value, child) {
                              return Transform.rotate(
                                angle: value * 0.1,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppStrings.getCoachTipTitle(locale),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: -0.5,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.auto_awesome_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.getPomodoroTip(locale),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.95,
                                        ),
                                        height: 1.6,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
