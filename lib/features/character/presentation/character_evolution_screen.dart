import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_coach/shared/data/providers.dart';
import 'package:learning_coach/shared/services/gamification_service.dart';
import 'package:learning_coach/shared/models/gamification_models.dart';

/// Character Evolution Screen - Evolution Tree Display
class CharacterEvolutionScreen extends ConsumerStatefulWidget {
  const CharacterEvolutionScreen({super.key});

  @override
  ConsumerState<CharacterEvolutionScreen> createState() => _CharacterEvolutionScreenState();
}

class _CharacterEvolutionScreenState extends ConsumerState<CharacterEvolutionScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for current stage
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userStats = ref.watch(userStatsProvider);
    final currentFeatures = GamificationService.getStageFeatures(userStats.stage);
    final currentLevel = userStats.level;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Evrim Ağacım',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              currentFeatures.primaryColor,
              currentFeatures.primaryColor.withOpacity(0.6),
              currentFeatures.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Current Stage Card
                _buildCurrentStageCard(userStats, currentFeatures),
                
                const SizedBox(height: 30),
                
                // Evolution Tree
                _buildEvolutionTree(currentLevel),
                
                const SizedBox(height: 30),
                
                // Stage Bonuses Info
                _buildBonusesCard(currentFeatures),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStageCard(userStats, StageFeatures features) {
    final assetPath = GamificationService.getCharacterAssetPath(userStats.stage);
    final levelProgress = GamificationService.levelProgress(userStats.xp, userStats.level);
    final xpToNext = GamificationService.xpToNextLevel(userStats.xp, userStats.level);
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: features.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Character Image
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: features.primaryColor.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [features.primaryColor, features.secondaryColor],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              features.emoji,
                              style: const TextStyle(fontSize: 80),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  features.title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: features.primaryColor,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Power Name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: features.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '⚡ ${features.powerName}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: features.primaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  features.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatBadge('Seviye', '${userStats.level}', features.primaryColor),
                    _buildStatBadge('Altın', '${userStats.gold}', const Color(0xFFF59E0B)),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress to Next Level
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sonraki Seviyeye',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$xpToNext XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: features.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: levelProgress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation(features.primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEvolutionTree(int currentLevel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌳 Evrim Ağacı',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          
          _buildEvolutionStage(AvatarStage.forest, 36, currentLevel),
          _buildTreeBranch(),
          _buildEvolutionStage(AvatarStage.tree, 26, currentLevel),
          _buildTreeBranch(),
          _buildEvolutionStage(AvatarStage.bloom, 17, currentLevel),
          _buildTreeBranch(),
          _buildEvolutionStage(AvatarStage.sprout, 9, currentLevel),
          _buildTreeBranch(),
          _buildEvolutionStage(AvatarStage.seed, 1, currentLevel),
        ],
      ),
    );
  }

  Widget _buildEvolutionStage(AvatarStage stage, int requiredLevel, int currentLevel) {
    final features = GamificationService.getStageFeatures(stage);
    final isUnlocked = currentLevel >= requiredLevel;
    final isCurrent = GamificationService.getAvatarStage(currentLevel) == stage;
    
    return AnimatedBuilder(
      animation: isCurrent ? _glowAnimation : const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        return Opacity(
          opacity: isUnlocked ? 1.0 : 0.4,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrent 
                  ? features.primaryColor.withOpacity(0.1 + (_glowAnimation.value * 0.1))
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent 
                    ? features.primaryColor.withOpacity(0.3 + (_glowAnimation.value * 0.3))
                    : Colors.grey[300]!,
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Stage Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isUnlocked ? features.primaryColor : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      features.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            features.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? features.primaryColor : Colors.grey[600],
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: features.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Şu an',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seviye $requiredLevel${stage == AvatarStage.forest ? '+' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (isUnlocked) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+${features.xpBonus}% XP | +${features.goldBonus}% Altın',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: features.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Lock/Unlock Icon
                Icon(
                  isUnlocked ? Icons.check_circle : Icons.lock,
                  color: isUnlocked ? features.primaryColor : Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTreeBranch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 2,
            height: 20,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildBonusesCard(StageFeatures features) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎁 Mevcut Bonuslar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          _buildBonusRow(
            '⚡ XP Bonusu',
            '+${features.xpBonus}%',
            'Her çalışmada ekstra XP kazan',
            features.primaryColor,
          ),
          
          const Divider(height: 24),
          
          _buildBonusRow(
            '💰 Altın Bonusu',
            '+${features.goldBonus}%',
            'Görevlerden daha fazla altın kazan',
            const Color(0xFFF59E0B),
          ),
          
          if (features.xpBonus == 0 && features.goldBonus == 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seviye atladıkça bonusların artacak!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBonusRow(String title, String value, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
