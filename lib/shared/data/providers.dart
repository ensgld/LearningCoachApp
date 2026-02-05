import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_coach/shared/data/mock_data_repository.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/services/gamification_service.dart';
import 'package:learning_coach/shared/services/api_service.dart';
import 'package:learning_coach/shared/data/api_document_repository.dart';
import 'package:learning_coach/shared/data/api_goal_repository.dart';
import 'package:learning_coach/shared/data/api_stats_repository.dart';
import 'package:learning_coach/shared/data/api_study_session_repository.dart';
import 'package:learning_coach/shared/providers/auth_provider.dart';

part 'providers.g.dart';

// --- API REPOSITORIES ---

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

// --- DATA PROVIDERS (API BASED) ---

@riverpod
Future<List<Goal>> goals(Ref ref) async {
  return ref.watch(apiGoalRepositoryProvider).getGoals();
}

@riverpod
Future<List<Document>> documents(Ref ref) async {
  return ref.watch(apiDocumentRepositoryProvider).getDocuments();
}

@riverpod
Future<Map<String, dynamic>> userProgress(Ref ref) async {
  return ref.watch(apiStatsRepositoryProvider).getUserProgress();
}

@riverpod
Future<List<DailyStats>> dailyStats(Ref ref) async {
  return ref.watch(apiStatsRepositoryProvider).getDailyStats();
}

// --- CHAT PROVIDER (1. DOSYADAKİ ÇALIŞAN KOD) ---

@Riverpod(keepAlive: true)
class ChatMessages extends _$ChatMessages {
  final _apiService = ApiService();

  @override
  List<CoachMessage> build() {
    return List.from(MockDataRepository.initialChat);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Kullanıcı mesajını hemen ekrana ekle (Optimistic UI)
    final userMessage = CoachMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];

    try {
      // 2. API üzerinden cevabı al
      final responseText = await _apiService.sendChatMessage(text);

      // 3. AI Cevabını listeye ekle
      final aiMessage = CoachMessage(
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = [...state, aiMessage];
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      final errorMessage = CoachMessage(
        text: "Üzgünüm, şu an bağlantı kuramıyorum. Hata: ${e.toString()}",
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    }
  }
}

// --- GAMIFICATION PROVIDER (API LOAD DESTEKLİ) ---

@riverpod
class UserStatsNotifier extends _$UserStatsNotifier {
  @override
  UserStats build() {
    // API'den verileri yükle
    _loadStats();

    // İlk değer (yüklenene kadar)
    return const UserStats(
      currentLevel: 1,
      currentXP: 0,
      totalGold: 100,
      stage: AvatarStage.seed,
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

  void addXP(int amount) {
    if (amount <= 0) return;

    int newXP = state.currentXP + amount;
    int newLevel = GamificationService.calculateLevel(newXP);
    final newStage = GamificationService.getAvatarStage(newLevel);

    state = state.copyWith(
      currentXP: newXP,
      currentLevel: newLevel,
      stage: newStage,
    );
  }

  void addGold(int amount) {
    if (amount <= 0) return;
    state = state.copyWith(totalGold: state.totalGold + amount);
  }

  String getCharacterAssetPath() {
    return GamificationService.getCharacterAssetPath(state.stage);
  }

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

  void awardTaskRewards() {
    final goldGained = GamificationService.calculateTaskGoldReward(state.stage);
    addGold(goldGained);
  }

  void purchaseItem(String itemId, int cost) {
    if (state.totalGold >= cost && !state.purchasedItemIds.contains(itemId)) {
      state = state.copyWith(
        totalGold: state.totalGold - cost,
        purchasedItemIds: [...state.purchasedItemIds, itemId],
      );
    }
  }

  void equipItem(String category, String itemId) {
    if (state.purchasedItemIds.contains(itemId)) {
      final updated = Map<String, String>.from(state.equippedItems);
      updated[category] = itemId;
      state = state.copyWith(equippedItems: updated);
    }
  }

  void unequipItem(String category) {
    final updated = Map<String, String>.from(state.equippedItems);
    updated.remove(category);
    state = state.copyWith(equippedItems: updated);
  }

  void updateStats(UserStats newStats) {
    state = newStats;
  }
}
