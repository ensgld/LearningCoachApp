import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/core/constants/app_strings.dart';
import 'package:learning_coach/core/providers/locale_provider.dart';
import 'package:learning_coach/features/garden/presentation/garden_screen.dart';
import 'package:learning_coach/features/home/presentation/widgets/home_widgets.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/models/gamification_models.dart';
import 'package:learning_coach/shared/services/gamification_service.dart';
import 'package:learning_coach/shared/widgets/avatar_character.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    // Breathing animation for character
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final userStats = ref.watch(userStatsProvider);
    final levelProgress = GamificationService.levelProgress(
      userStats.xp,
      userStats.level,
    );
    final xpToNext = GamificationService.xpToNextLevel(
      userStats.xp,
      userStats.level,
    );
    final stageName = GamificationService.getLocalizedStageName(
      userStats.stage,
      locale,
    );
    final powerName = GamificationService.getLocalizedPowerName(
      userStats.stage,
      locale,
    );
    final stageFeatures = GamificationService.getStageFeatures(userStats.stage);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              stageFeatures.secondaryColor.withValues(alpha: 0.3),
              stageFeatures.primaryColor.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Hero Header with Avatar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                child: Column(
                  children: [
                    // Level Badge Centered or Leading?
                    // Let's keep it clean. Just show Level Badge.
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              stageFeatures.primaryColor,
                              stageFeatures.primaryColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: stageFeatures.primaryColor.withValues(alpha: 
                                0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              stageFeatures.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Lv ${userStats.level}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tappable Tree & Pot with Breathing Animation
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GardenScreen(),
                          ),
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _breathingAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _breathingAnimation.value,
                            child: CircularLevelProgress(
                              progress: levelProgress,
                              level: userStats.level,
                              size: 200,
                              child: _buildTreeAndPotPreview(userStats),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tap Hint
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: stageFeatures.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: stageFeatures.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 16,
                            color: stageFeatures.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.getTouchToSeeTree(locale),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: stageFeatures.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Stage Name & XP Info
                    Text(
                      stageName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: stageFeatures.primaryColor,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // Power Name
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: stageFeatures.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⚡ $powerName',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: stageFeatures.primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bonus Indicators
                    if (stageFeatures.xpBonus > 0)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildBonusBadge(
                          '⚡ +${stageFeatures.xpBonus}% XP',
                          stageFeatures.primaryColor,
                        ),
                      ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${AppStrings.getNextLevel(locale)}: $xpToNext XP',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Quest Board / Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const TodayPlanCard(),
                  const SizedBox(height: 20),
                  const QuickKaizenCard(),
                  const SizedBox(height: 20),
                  const ProgressSummaryCard(),
                  const SizedBox(height: 20),
                  const CoachTipCard(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeAndPotPreview(UserStats userStats) {
    final treeAsset = GamificationService.getTreeAssetPath(userStats.level);

    // Compact size for home screen preview
    const double containerSize = 150.0;

    // Pot logic (Static base)
    const double potHeight = containerSize * 0.35;
    const double potWidth = containerSize * 0.55;

    // Tree dimensions relative to asset aspect ratio (approx)
    const double treeHeight = containerSize * 0.8;
    const double treeWidth = treeHeight * 0.85;

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Tree Layer (Image Asset)
          Positioned(
            bottom: containerSize * 0.28, // Just above pot bottom
            child: SizedBox(
              width: treeWidth,
              height: treeHeight,
              child: Image.asset(
                treeAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.green[300]!, Colors.green[700]!],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Icon(Icons.park, size: 50, color: Colors.white70),
                    ),
                  );
                },
              ),
            ),
          ),

          // Pot Layer (Front)
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
                  // Soil
                  Positioned(
                    top: potHeight * 0.15,
                    left: potWidth * 0.15,
                    right: potWidth * 0.15,
                    child: Container(
                      height: potHeight * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.brown[900],
                        borderRadius: BorderRadius.circular(4),
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

  Widget _buildBonusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
