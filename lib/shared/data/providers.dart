import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_coach/shared/data/mock_data_repository.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/services/gamification_service.dart';
import 'package:learning_coach/shared/services/api_service.dart'; // Yeni servisi import et

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

// --- CHAT PROVIDER GÜNCELLEMESİ ---
@Riverpod(keepAlive: true)
class ChatMessages extends _$ChatMessages {
  final _apiService = ApiService();

  @override
  List<CoachMessage> build() {
    // Başlangıçta boş veya mock datadan ilk mesajı getirebilirsin
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

    // Mevcut listeye kullanıcı mesajını ekle
    state = [...state, userMessage];

    try {
      // 2. Yükleniyor durumu eklemek istersen burada "typing" animasyonu eklenebilir
      // Şimdilik direkt isteği atıyoruz.

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

// --- Enhanced Gamification Providers (Aynen Kalıyor) ---
@riverpod
class UserStatsNotifier extends _$UserStatsNotifier {
  @override
  UserStats build() {
    return const UserStats(
      currentLevel: 1,
      currentXP: 0,
      totalGold: 100,
      stage: AvatarStage.seed,
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
