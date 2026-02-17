import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/gamification_models.dart';
import 'package:learning_coach/shared/services/gamification_service.dart';
import 'package:learning_coach/shared/widgets/reward_popups.dart';

class SessionRunningScreen extends ConsumerStatefulWidget {
  final String goalId;
  final int durationMinutes;

  const SessionRunningScreen({
    super.key,
    required this.goalId,
    required this.durationMinutes,
  });

  @override
  ConsumerState<SessionRunningScreen> createState() =>
      _SessionRunningScreenState();
}

class _SessionRunningScreenState extends ConsumerState<SessionRunningScreen>
    with SingleTickerProviderStateMixin {
  // Timer
  late int _secondsRemaining;
  Timer? _timer;
  bool _isPaused = false;

  // Animation
  late AnimationController _swayController;
  late Animation<double> _swayAnimation;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationMinutes * 60;
    _startTimer();

    _swayController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _swayAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOut),
    );
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

  // ... (keep existing dispose and _timerString)

  @override
  void dispose() {
    _timer?.cancel();
    _swayController.dispose();
    super.dispose();
  }

  String get _timerString {
    final minutes = (_secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // ... (keep existing build logic but use widget.durationMinutes for progress calculation)
    final locale = ref.watch(localeProvider);
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
              scheme.surface.withValues(alpha: 0.95),
            ],
            stops: const [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '⚡ ${AppStrings.getTrainingMode(locale)}',
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
                // Training Avatar with Progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value:
                            1 -
                            (_secondsRemaining / (widget.durationMinutes * 60)),
                        strokeWidth: 12,
                        backgroundColor: scheme.surfaceContainerHighest,
                        color: scheme.primary,
                      ),
                    ),
                    // Plant with Swaying Animation
                    _buildSwayingPlant(userStats, scheme),
                  ],
                ),
                const SizedBox(height: 32),
                // Timer Display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primaryContainer.withValues(alpha: 0.6),
                        scheme.secondaryContainer.withValues(alpha: 0.6),
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
                  '${AppStrings.getGoalPrefix(locale)}: ...', // Could fetch goal title if we want
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // Controls
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
                        _isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton.icon(
                      onPressed: () => _finishSession(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: Text(AppStrings.getFinishBtn(locale)),
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

  void _finishSession() {
    _timer?.cancel();

    final elapsedSeconds = (widget.durationMinutes * 60) - _secondsRemaining;
    final elapsedMinutes = elapsedSeconds ~/ 60;
    final currentStats = ref.read(userStatsProvider);

    // Minimum 10 minutes required for rewards
    if (elapsedMinutes < 10) {
      // Show VictoryPopup in "Early Exit" mode (0 XP)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => VictoryPopup(
          xpEarned: 0,
          newLevel: currentStats.level,
          leveledUp: false,
          onContinue: () {
            // "Bitir" pressed
            Navigator.of(context).pop(); // Close dialog
            _completeSession(
              elapsedSeconds,
              elapsedMinutes,
              showSuccessDialog: false,
            );
            if (mounted && context.canPop()) {
              context.pop(); // Close screen
            }
          },
          onResume: () {
            // "Devam Et" pressed
            Navigator.of(context).pop(); // Close dialog
            // Timer is already paused by logic flow? No, _finishSession cancels it.
            // We need to decide if we restart it or if we just let it be.
            // _finishSession cancelled it. We should probably restart it or not cancel it until confirmed.
            // Wait, the previous logic cancelled timer at start of _finishSession.
            // If we resume, we need to restart timer.
            _startTimer();
          },
        ),
      );
    } else {
      _completeSession(elapsedSeconds, elapsedMinutes);
    }
  }

  Future<void> _completeSession(
    int elapsedSeconds,
    int elapsedMinutes, {
    bool showSuccessDialog = true,
  }) async {
    try {
      await ref
          .read(apiStudySessionRepositoryProvider)
          .createSession(
            goalId: widget.goalId,
            durationMinutes: widget.durationMinutes, // Planned duration
            actualDurationSeconds: elapsedSeconds, // Actual duration
          );

      // Award rewards
      final currentStats = ref.read(userStatsProvider);
      final newStats = GamificationService.awardStudyRewards(
        currentStats,
        elapsedMinutes, // Corrected to use minutes
      );
      final leveledUp = newStats.level > currentStats.level;

      // Update stats
      ref.read(userStatsProvider.notifier).updateStats(newStats);

      // Show victory popup if requested (and if we have rewards or it's a normal finish)
      // Actually strictly respecting the flag is safer for the double-dialog issue.
      if (showSuccessDialog && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => VictoryPopup(
            xpEarned: GamificationService.calculateXpReward(
              elapsedMinutes,
              currentStats.stage,
            ),
            newLevel: newStats.level,
            leveledUp: leveledUp,
            onContinue: () {
              Navigator.of(context).pop(); // Close dialog
              context.pop(); // Close running screen
            },
            // onResume not needed here
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kayıt hatası: $e')));
      }
    }
  }

  Widget _buildSwayingPlant(UserStats userStats, ColorScheme scheme) {
    final treeAsset = GamificationService.getTreeAssetPath(userStats.level);
    const double containerSize = 220.0;

    // Pot logic (Static base)
    const double potHeight = containerSize * 0.35;
    const double potWidth = containerSize * 0.55;

    // Tree dimensions
    const double treeHeight = containerSize * 0.8;
    const double treeWidth = treeHeight * 0.85;

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Tree Layer (Animated)
          Positioned(
            bottom: containerSize * 0.28,
            child: AnimatedBuilder(
              animation: _swayAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _isPaused ? 0 : _swayAnimation.value,
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: treeWidth,
                    height: treeHeight,
                    child: Image.asset(
                      treeAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.park,
                          size: 80,
                          color: Colors.green,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Pot Layer (Static Front)
          Positioned(
            bottom: containerSize * 0.25,
            child: Container(
              width: potWidth,
              height: potHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.brown[400]!, Colors.brown[700]!],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Pot rim
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: potHeight * 0.2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.brown[300]!, Colors.brown[500]!],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  // Soil or Label area
                  Positioned(
                    top: potHeight * 0.3,
                    left: potWidth * 0.2,
                    right: potWidth * 0.2,
                    child: Container(
                      height: potHeight * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.brown[900]?.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.eco,
                          color: Colors.green[200]!.withValues(alpha: 0.5),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
