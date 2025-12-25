import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_coach/shared/data/mock_data_repository.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/models/gamification_models.dart';
import 'package:learning_coach/shared/services/gamification_service.dart';

part 'providers.g.dart';

// Goals
@riverpod
List<Goal> goals(Ref ref) {
  return MockDataRepository.goals;
}

// Documents
@riverpod
List<Document> documents(Ref ref) {
  return MockDataRepository.documents;
}

// Chat
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<CoachMessage> build() {
    return List.from(MockDataRepository.initialChat);
  }

  void addMessage(CoachMessage message) {
    state = [...state, message];
  }
}

// --- Enhanced Gamification Providers ---

/// Main Gamification Notifier with complete XP, Leveling, and Gold logic
@riverpod
class UserStatsNotifier extends _$UserStatsNotifier {
  @override
  UserStats build() {
    // Initial stats - can be loaded from storage later
    return const UserStats(
      currentLevel: 1,
      currentXP: 0,
      totalGold: 100, // Starting gold
      stage: AvatarStage.seed,  // Başlangıç evresi: Tohum
      equippedItems: {},
      purchasedItemIds: [],
    );
  }

  /// Add XP and automatically handle leveling up
  void addXP(int amount) {
    if (amount <= 0) return;
    
    int newXP = state.currentXP + amount;
    int newLevel = GamificationService.calculateLevel(newXP);
    
    // Update stage based on new level
    final newStage = GamificationService.getAvatarStage(newLevel);
    
    state = state.copyWith(
      currentXP: newXP,
      currentLevel: newLevel,
      stage: newStage,
    );
  }

  /// Add gold
  void addGold(int amount) {
    if (amount <= 0) return;
    state = state.copyWith(totalGold: state.totalGold + amount);
  }

  /// Get character asset path based on current level
  String getCharacterAssetPath() {
    return GamificationService.getCharacterAssetPath(state.stage);
  }

  /// Award XP and Gold for study session
  void awardStudyRewards(int studyMinutes) {
    final xpGained = GamificationService.calculateXpReward(studyMinutes, state.stage);
    final goldGained = GamificationService.calculateSessionGoldReward(state.stage);
    
    addXP(xpGained);
    addGold(goldGained);
  }

  /// Award Gold for task completion
  void awardTaskRewards() {
    final goldGained = GamificationService.calculateTaskGoldReward(state.stage);
    addGold(goldGained);
  }

  /// Purchase item with gold
  void purchaseItem(String itemId, int cost) {
    if (state.totalGold >= cost && !state.purchasedItemIds.contains(itemId)) {
      state = state.copyWith(
        totalGold: state.totalGold - cost,
        purchasedItemIds: [...state.purchasedItemIds, itemId],
      );
    }
  }

  /// Equip item by category
  void equipItem(String category, String itemId) {
    if (state.purchasedItemIds.contains(itemId)) {
      final updated = Map<String, String>.from(state.equippedItems);
      updated[category] = itemId;
      state = state.copyWith(equippedItems: updated);
    }
  }

  /// Unequip item by category
  void unequipItem(String category) {
    final updated = Map<String, String>.from(state.equippedItems);
    updated.remove(category);
    state = state.copyWith(equippedItems: updated);
  }

  /// Update complete stats (for advanced use cases)
  void updateStats(UserStats newStats) {
    state = newStats;
  }
}

