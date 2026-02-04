import 'package:learning_coach/shared/data/api_document_repository.dart';
import 'package:learning_coach/shared/data/api_goal_repository.dart';
import 'package:learning_coach/shared/data/api_stats_repository.dart';
import 'package:learning_coach/shared/data/api_study_session_repository.dart';
import 'package:learning_coach/shared/data/mock_data_repository.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/providers/auth_provider.dart'; // For apiServiceProvider
import 'package:learning_coach/shared/services/gamification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
ApiGoalRepository apiGoalRepository(Ref ref) {
  return ApiGoalRepository(ref.watch(apiServiceProvider));
}

@riverpod
ApiStudySessionRepository apiStudySessionRepository(Ref ref) {
  return ApiStudySessionRepository(ref.watch(apiServiceProvider));
}

@riverpod
ApiDocumentRepository apiDocumentRepository(Ref ref) {
  return ApiDocumentRepository(ref.watch(apiServiceProvider));
}

@riverpod
ApiStatsRepository apiStatsRepository(Ref ref) {
  return ApiStatsRepository(ref.watch(apiServiceProvider));
}

// Goals
@riverpod
Future<List<Goal>> goals(Ref ref) async {
  return ref.watch(apiGoalRepositoryProvider).getGoals();
}

// Documents
@riverpod
Future<List<Document>> documents(Ref ref) async {
  return ref.watch(apiDocumentRepositoryProvider).getDocuments();
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

@riverpod
Future<Map<String, dynamic>> userProgress(Ref ref) async {
  return ref.watch(apiStatsRepositoryProvider).getUserProgress();
}

@riverpod
Future<List<DailyStats>> dailyStats(Ref ref) async {
  return ref.watch(apiStatsRepositoryProvider).getDailyStats();
}

// --- Enhanced Gamification Providers ---

/// Main Gamification Notifier with complete XP, Leveling, and Gold logic
@riverpod
class UserStatsNotifier extends _$UserStatsNotifier {
  @override
  UserStats build() {
    // Attempt to load stats from API
    _loadStats();

    // Initial stats (placeholder while loading)
    return const UserStats(
      currentLevel: 1,
      currentXP: 0,
      totalGold: 100, // Starting gold
      stage: AvatarStage.seed, // Başlangıç evresi: Tohum
      equippedItems: {},
      purchasedItemIds: [],
    );
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ref.read(apiStatsRepositoryProvider).getUserStats();
      state = stats;
    } catch (e) {
      print('Error loading stats: $e');
    }
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
    final xpGained = GamificationService.calculateXpReward(
      studyMinutes,
      state.stage,
    );
    final goldGained = GamificationService.calculateSessionGoldReward(
      state.stage,
    );

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
