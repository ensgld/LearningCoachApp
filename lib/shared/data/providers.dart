import 'package:flutter/foundation.dart';
import 'package:learning_coach/shared/data/api_chat_repository.dart';
import 'package:learning_coach/shared/data/api_document_repository.dart';
import 'package:learning_coach/shared/data/api_goal_repository.dart';
import 'package:learning_coach/shared/data/api_stats_repository.dart';
import 'package:learning_coach/shared/data/api_study_session_repository.dart';
import 'package:learning_coach/shared/data/mock_data_repository.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/providers/auth_provider.dart';
import 'package:learning_coach/shared/services/gamification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
ApiChatRepository apiChatRepository(Ref ref) {
  return ApiChatRepository(ref.watch(apiServiceProvider));
}

@riverpod
ApiStatsRepository apiStatsRepository(Ref ref) {
  return ApiStatsRepository(ref.watch(apiServiceProvider));
}

// --- DATA PROVIDERS (API BASED) ---

@riverpod
Future<List<Goal>> goals(Ref ref) async {
  try {
    return await ref.watch(apiGoalRepositoryProvider).getGoals();
  } catch (e) {
    debugPrint('Goals API failed, falling back to mock data: $e');
    return MockDataRepository.goals;
  }
}

@riverpod
Future<List<Document>> documents(Ref ref) async {
  try {
    return await ref.watch(apiDocumentRepositoryProvider).getDocuments();
  } catch (e) {
    debugPrint('Documents API failed, falling back to mock data: $e');
    return MockDataRepository.documents;
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

// --- CHAT PROVIDER (1. DOSYADAKİ ÇALIŞAN KOD) ---

@Riverpod(keepAlive: true)
class ChatMessages extends _$ChatMessages {
  final String _threadId = 'general_chat'; // Explicit thread ID
  bool _loaded = false;

  @override
  List<CoachMessage> build() {
    if (!_loaded) {
      _loaded = true;
      _loadHistory();
    }

    return [];
  }

  Future<void> _loadHistory() async {
    try {
      final repository = ref.read(apiChatRepositoryProvider);
      final result = await repository.getHistory(
        threadId: _threadId,
      ); // Pass threadId
      if (result.messages.isNotEmpty) {
        state = result.messages;
        // Optionally update threadId if backend returns a new one, but we prefer keeping ours if possible
        // _threadId = result.threadId ?? _threadId;
        return;
      }
      state = List.from(MockDataRepository.initialChat);
    } catch (e) {
      debugPrint('Chat history load failed, using mock data: $e');
      state = List.from(MockDataRepository.initialChat);
    }
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
      final repository = ref.read(apiChatRepositoryProvider);
      final response = await repository.sendMessage(text, threadId: _threadId);
      // _threadId = response.threadId ?? _threadId; // Remove override to keep distinct threadId

      // 3. AI Cevabını listeye ekle
      final aiMessage = CoachMessage(
        text: response.answer,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = [...state, aiMessage];
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      final errorMessage = CoachMessage(
        text: 'Üzgünüm, şu an bağlantı kuramıyorum. Hata: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    }
  }
}

@Riverpod(keepAlive: true)
class CoachTipMessages extends _$CoachTipMessages {
  final String _threadId = 'coach_tip_daily'; // Explicit thread ID
  // Coach Tip için history yüklemeye gerek var mı?
  // "Sadece 1 defa o gün neler yaptığını göndersin" denildiğine göre
  // belki de her gün sıfırlanmalı veya sadece o session için tutulmalı.
  // Kullanıcı "her şeyi konuşabilir" dediği için history tutmak mantıklı olabilir
  // ama "koçtan ipucu" kısmında user 1 kere basıp sonucu görüyor.
  // Biz yine de standart chat yapısını koruyalım, ayrı bir state olsun.

  @override
  List<CoachMessage> build() {
    return [];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = CoachMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];

    try {
      final repository = ref.read(apiChatRepositoryProvider);
      // Farklı bir thread veya context gerekebilir ama şimdilik aynı endpoint
      final response = await repository.sendMessage(text, threadId: _threadId);
      // _threadId = response.threadId ?? _threadId; // Remove override

      final aiMessage = CoachMessage(
        text: response.answer,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = [...state, aiMessage];
    } catch (e) {
      final errorMessage = CoachMessage(
        text: 'Bağlantı hatası: ${e.toString()}',
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

  Future<void> _persistStats(UserStats newStats) async {
    state = newStats;
    try {
      await ref.read(apiStatsRepositoryProvider).updateUserStats(newStats);
    } catch (e) {
      print('Error persisting stats: $e');
      // Optionally revert state or show error
    }
  }

  void addXP(int amount) {
    if (amount <= 0) return;

    int newXP = state.currentXP + amount;
    int newLevel = GamificationService.calculateLevel(newXP);
    final newStage = GamificationService.getAvatarStage(newLevel);

    final newStats = state.copyWith(
      currentXP: newXP,
      currentLevel: newLevel,
      stage: newStage,
    );
    _persistStats(newStats);
  }

  void addGold(int amount) {
    if (amount <= 0) return;
    final newStats = state.copyWith(totalGold: state.totalGold + amount);
    _persistStats(newStats);
  }

  String getCharacterAssetPath() {
    return GamificationService.getCharacterAssetPath(state.stage);
  }

  void awardStudyRewards(int studyMinutes) {
    // This is likely not used if we use updateStats directly from screen
    // But keeping it consistent
    final xpGained = GamificationService.calculateXpReward(
      studyMinutes,
      state.stage,
    );
    final goldGained = GamificationService.calculateSessionGoldReward(
      state.stage,
    );

    // Calculate new state logic duplicated from addXP/addGold but combined
    int newXP = state.currentXP + xpGained;
    int newLevel = GamificationService.calculateLevel(newXP);
    final newStage = GamificationService.getAvatarStage(newLevel);
    int newGold = state.totalGold + goldGained;

    final newStats = state.copyWith(
      currentXP: newXP,
      currentLevel: newLevel,
      stage: newStage,
      totalGold: newGold,
    );
    _persistStats(newStats);
  }

  void awardTaskRewards() {
    final xpGained = GamificationService.calculateTaskXpReward(state.stage);
    final goldGained = GamificationService.calculateTaskGoldReward(state.stage);

    // Calculate new state logic
    int newXP = state.currentXP + xpGained;
    int newLevel = GamificationService.calculateLevel(newXP);
    final newStage = GamificationService.getAvatarStage(newLevel);
    int newGold = state.totalGold + goldGained;

    final newStats = state.copyWith(
      currentXP: newXP,
      currentLevel: newLevel,
      stage: newStage,
      totalGold: newGold,
    );
    _persistStats(newStats);
  }

  void purchaseItem(String itemId, int cost) {
    if (state.totalGold >= cost && !state.purchasedItemIds.contains(itemId)) {
      final newStats = state.copyWith(
        totalGold: state.totalGold - cost,
        purchasedItemIds: [...state.purchasedItemIds, itemId],
      );
      _persistStats(newStats);
    }
  }

  void equipItem(String category, String itemId) {
    if (state.purchasedItemIds.contains(itemId)) {
      final updated = Map<String, String>.from(state.equippedItems);
      updated[category] = itemId;
      final newStats = state.copyWith(equippedItems: updated);
      _persistStats(newStats);
    }
  }

  void unequipItem(String category) {
    final updated = Map<String, String>.from(state.equippedItems);
    updated.remove(category);
    final newStats = state.copyWith(equippedItems: updated);
    _persistStats(newStats);
  }

  void updateStats(UserStats newStats) {
    _persistStats(newStats);
  }
}
