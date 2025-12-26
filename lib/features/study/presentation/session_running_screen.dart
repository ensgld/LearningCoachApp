import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/features/study/application/study_controller.dart';
import 'package:learning_coach/shared/widgets/avatar_character.dart';
import 'package:learning_coach/shared/widgets/reward_popups.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/services/gamification_service.dart';

class SessionRunningScreen extends ConsumerStatefulWidget {
  const SessionRunningScreen({super.key});

  @override
  ConsumerState<SessionRunningScreen> createState() => _SessionRunningScreenState();
}

class _SessionRunningScreenState extends ConsumerState<SessionRunningScreen> {
  late int _secondsRemaining;
  late int _totalSeconds;
  Timer? _timer;
  bool _isPaused = false;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    final studyState = ref.read(studyControllerProvider);
    _totalSeconds = (studyState?.durationMinutes ?? 25) * 60;
    _secondsRemaining = _totalSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
            _finishSession();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerString {
    final minutes = (_secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final studyState = ref.watch(studyControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final userStats = ref.watch(userStatsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F3FF),
              const Color(0xFFFDF4FF),
              const Color(0xFFF0FDFA),
              scheme.surface.withOpacity(0.95),
            ],
            stops: const [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '⚡ Eğitim Modu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: 1 - (_secondsRemaining / _totalSeconds),
                        strokeWidth: 12,
                        backgroundColor: scheme.surfaceContainerHighest,
                        color: scheme.primary,
                      ),
                    ),
                    AvatarCharacter(
                      stage: userStats.stage.name,
                      size: 180,
                      isAnimating: !_isPaused,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primaryContainer.withOpacity(0.6),
                        scheme.secondaryContainer.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _timerString,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '🎯 Hedef: ${studyState?.goalId != null ? ref.read(goalsProvider).firstWhere((g) => g.id == studyState!.goalId).title : "Çalışma Seansı"}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.large(
                      onPressed: () {
                        setState(() {
                          _isPaused = !_isPaused;
                        });
                      },
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(
                        _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton.icon(
                      onPressed: () => _finishSession(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      ),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Bitir'),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _finishSession() async {
    _timer?.cancel();
    
    // Calculate actual study time in seconds
    final actualSeconds = _totalSeconds - _secondsRemaining;
    final studyMinutes = actualSeconds ~/ 60;
    
    // Update study controller
    ref.read(studyControllerProvider.notifier).finishSession(actualSeconds);
    
    // Award rewards
    final currentStats = ref.read(userStatsProvider);
    final newStats = GamificationService.awardStudyRewards(currentStats, studyMinutes);
    final leveledUp = newStats.level > currentStats.level;
    
    // Update stats
    ref.read(userStatsProvider.notifier).updateStats(newStats);
    
    // Show victory popup
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryPopup(
        xpEarned: GamificationService.calculateXpReward(studyMinutes, currentStats.stage),
        goldEarned: GamificationService.calculateSessionGoldReward(currentStats.stage),
        newLevel: newStats.level,
        leveledUp: leveledUp,
        onContinue: () {
          Navigator.of(context).pop();
          context.go('/study/quiz');
        },
      ),
    );
  }
}
