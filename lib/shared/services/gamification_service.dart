import 'dart:math';
import 'package:flutter/material.dart';
import 'package:learning_coach/shared/models/gamification_models.dart';

/// Gamification Service - Evolution Story Game Mechanics
class GamificationService {
  // --- XP & Leveling Constants ---
  static const int baseXpPerLevel = 100;
  static const double xpMultiplier = 1.5;
  
  // --- Base Reward Constants ---
  static const int baseXpPerMinute = 10;
  static const int baseGoldPerTask = 50;
  static const int baseGoldPerSession = 25;
  
  // --- Evolution Milestones ---
  static const int seedMaxLevel = 8;
  static const int sproutMaxLevel = 16;
  static const int bloomMaxLevel = 25;
  static const int treeMaxLevel = 35;

  /// Calculate XP with stage bonus
  static int calculateXpWithBonus(int baseXp, AvatarStage stage) {
    final features = getStageFeatures(stage);
    final bonusXp = (baseXp * features.xpBonus / 100).round();
    return baseXp + bonusXp;
  }
  
  /// Calculate Gold with stage bonus
  static int calculateGoldWithBonus(int baseGold, AvatarStage stage) {
    final features = getStageFeatures(stage);
    final bonusGold = (baseGold * features.goldBonus / 100).round();
    return baseGold + bonusGold;
  }
  
  /// Calculate level from total XP
  /// Formula: Level = floor(sqrt(XP / baseXpPerLevel)) + 1
  static int calculateLevel(int totalXp) {
    if (totalXp <= 0) return 1;
    return (sqrt(totalXp / baseXpPerLevel)).floor() + 1;
  }
  
  /// Get XP reward for study with stage bonus
  static int calculateXpReward(int studyMinutes, AvatarStage stage) {
    final baseXp = studyMinutes * baseXpPerMinute;
    return calculateXpWithBonus(baseXp, stage);
  }
  
  /// Get Gold reward for task with stage bonus
  static int calculateTaskGoldReward(AvatarStage stage) {
    return calculateGoldWithBonus(baseGoldPerTask, stage);
  }
  
  /// Get Gold reward for session with stage bonus
  static int calculateSessionGoldReward(AvatarStage stage) {
    return calculateGoldWithBonus(baseGoldPerSession, stage);
  }

  /// Calculate XP required for next level
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    return (pow((level - 1), 2) * baseXpPerLevel).toInt();
  }

  /// Get XP needed for current level progress
  static int xpToNextLevel(int totalXp, int currentLevel) {
    final nextLevelXp = xpForLevel(currentLevel + 1);
    return nextLevelXp - totalXp;
  }

  /// Get progress percentage to next level (0.0 to 1.0)
  static double levelProgress(int totalXp, int currentLevel) {
    final currentLevelXp = xpForLevel(currentLevel);
    final nextLevelXp = xpForLevel(currentLevel + 1);
    final levelRange = nextLevelXp - currentLevelXp;
    final xpInCurrentLevel = totalXp - currentLevelXp;
    
    if (levelRange <= 0) return 1.0;
    return (xpInCurrentLevel / levelRange).clamp(0.0, 1.0);
  }

  /// Determine avatar stage based on level - Evolution Story
  static AvatarStage getAvatarStage(int level) {
    if (level >= 36) return AvatarStage.forest;  // Level 36+ -> Orman (Ustalık)
    if (level >= 26) return AvatarStage.tree;    // Level 26-35 -> Ağaç (Olgunluk)
    if (level >= 17) return AvatarStage.bloom;   // Level 17-25 -> Çiçek (Gelişim)
    if (level >= 9) return AvatarStage.sprout;   // Level 9-16 -> Filiz (Büyüme)
    return AvatarStage.seed;                     // Level 1-8 -> Tohum (Başlangıç)
  }
  
  /// Get character asset path based on avatar stage
  static String getCharacterAssetPath(AvatarStage stage) {
    switch (stage) {
      case AvatarStage.seed:
        return 'assets/images/char_lvl1.jpeg';
      case AvatarStage.sprout:
        return 'assets/images/char_lvl2.jpeg';
      case AvatarStage.bloom:
        return 'assets/images/char_lvl3.jpeg';
      case AvatarStage.tree:
        return 'assets/images/char_lvl4.jpeg';
      case AvatarStage.forest:
        return 'assets/images/char_lvl5.jpeg';
    }
  }
  
  /// Get tree asset path based on level (for Garden Screen)
  static String getTreeAssetPath(int level) {
    if (level >= 40) return 'assets/images/tree_lvl5.png'; // Ancient Tree
    if (level >= 30) return 'assets/images/tree_lvl4.png'; // Mature Tree
    if (level >= 20) return 'assets/images/tree_lvl3.png'; // Young Tree
    if (level >= 10) return 'assets/images/tree_lvl2.png'; // Sapling
    return 'assets/images/tree_lvl1.png'; // Seed/Sprout
  }
  
  /// Get stage features - Each stage has unique bonuses
  static StageFeatures getStageFeatures(AvatarStage stage) {
    switch (stage) {
      case AvatarStage.seed:
        return const StageFeatures(
          title: '🌱 Tohum',
          description: 'Yolculuğun başlangıcı. Her çalışma seni güçlendirir.',
          powerName: 'Yeni Başlangıç',
          xpBonus: 0,
          goldBonus: 0,
          emoji: '🌱',
          primaryColor: Color(0xFF8B5CF6),
          secondaryColor: Color(0xFFDDD6FE),
        );
      case AvatarStage.sprout:
        return const StageFeatures(
          title: '🌿 Filiz',
          description: 'Büyümeye başladın! Artık daha hızlı öğreniyorsun.',
          powerName: 'Hızlı Büyüme',
          xpBonus: 10,  // +10% XP
          goldBonus: 5,  // +5% Gold
          emoji: '🌿',
          primaryColor: Color(0xFF10B981),
          secondaryColor: Color(0xFFD1FAE5),
        );
      case AvatarStage.bloom:
        return const StageFeatures(
          title: '🌸 Çiçek',
          description: 'Tüm potansiyelini açığa çıkarıyorsun!',
          powerName: 'Çiçek Açımı',
          xpBonus: 25,  // +25% XP
          goldBonus: 15, // +15% Gold
          emoji: '🌸',
          primaryColor: Color(0xFFEC4899),
          secondaryColor: Color(0xFFFCE7F3),
        );
      case AvatarStage.tree:
        return const StageFeatures(
          title: '🌳 Ağaç',
          description: 'Güçlü ve köklü bir bilgesin artık.',
          powerName: 'Bilgelik Ağacı',
          xpBonus: 40,  // +40% XP
          goldBonus: 30, // +30% Gold
          emoji: '🌳',
          primaryColor: Color(0xFF059669),
          secondaryColor: Color(0xFFA7F3D0),
        );
      case AvatarStage.forest:
        return const StageFeatures(
          title: '🌲 Orman',
          description: 'Efsanevi usta! Senin bilgin tüm ormanı besliyor.',
          powerName: 'Usta Ormanı',
          xpBonus: 60,  // +60% XP
          goldBonus: 50, // +50% Gold
          emoji: '🌲',
          primaryColor: Color(0xFF0369A1),
          secondaryColor: Color(0xFFBAE6FD),
        );
    }
  }
  
  /// Get avatar display name with level range
  static String getAvatarStageName(AvatarStage stage) {
    final features = getStageFeatures(stage);
    return features.title;
  }

  /// Update user stats after study session
  static UserStats awardStudyRewards(UserStats currentStats, int studyMinutes) {
    final xpGained = calculateXpReward(studyMinutes, currentStats.stage);
    final goldGained = calculateSessionGoldReward(currentStats.stage);
    final newXp = currentStats.currentXP + xpGained;
    final newGold = currentStats.totalGold + goldGained;
    final newLevel = calculateLevel(newXp);
    final newStage = getAvatarStage(newLevel);

    return currentStats.copyWith(
      currentXP: newXp,
      totalGold: newGold,
      currentLevel: newLevel,
      stage: newStage,
    );
  }

  /// Update user stats after task completion
  static UserStats awardTaskRewards(UserStats currentStats) {
    final goldGained = calculateTaskGoldReward(currentStats.stage);
    final newGold = currentStats.totalGold + goldGained;

    return currentStats.copyWith(totalGold: newGold);
  }

  /// Purchase item with gold
  static UserStats? purchaseItem(UserStats currentStats, InventoryItem item) {
    if (currentStats.purchasedItemIds.contains(item.id)) return null;
    if (currentStats.totalGold < item.goldCost) return null;
    
    final newGold = currentStats.totalGold - item.goldCost;
    final updatedPurchased = [...currentStats.purchasedItemIds, item.id];
    
    return currentStats.copyWith(
      totalGold: newGold,
      purchasedItemIds: updatedPurchased,
    );
  }

  /// Equip item
  static UserStats equipItem(UserStats currentStats, InventoryItem item) {
    if (!currentStats.purchasedItemIds.contains(item.id)) return currentStats;
    
    final updatedEquipped = Map<String, String>.from(currentStats.equippedItems);
    updatedEquipped[item.category.name] = item.id;
    
    return currentStats.copyWith(equippedItems: updatedEquipped);
  }

  /// Unequip item by category
  static UserStats unequipItem(UserStats currentStats, ItemCategory category) {
    final updatedEquipped = Map<String, String>.from(currentStats.equippedItems);
    updatedEquipped.remove(category.name);
    
    return currentStats.copyWith(equippedItems: updatedEquipped);
  }
}
