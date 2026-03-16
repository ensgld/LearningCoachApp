import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learning_coach/shared/models/models.dart';

// ─── FlashcardSet ─────────────────────────────────────────────────────────────

class FlashcardSet {
  final String id;
  final String documentId;
  final String documentTitle;
  final String difficulty;
  final int cardCount;
  final List<FlashCard> cards;
  final DateTime createdAt;
  final bool isGenerating;

  FlashcardSet({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.difficulty,
    required this.cardCount,
    required this.cards,
    required this.createdAt,
    this.isGenerating = false,
  });

  FlashcardSet copyWith({
    String? id,
    String? documentId,
    String? documentTitle,
    String? difficulty,
    int? cardCount,
    List<FlashCard>? cards,
    DateTime? createdAt,
    bool? isGenerating,
  }) {
    return FlashcardSet(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      difficulty: difficulty ?? this.difficulty,
      cardCount: cardCount ?? this.cardCount,
      cards: cards ?? this.cards,
      createdAt: createdAt ?? this.createdAt,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 'easy': return 'Kolay';
      case 'hard':  return 'Zor';
      default:      return 'Orta';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'documentId': documentId,
    'documentTitle': documentTitle,
    'difficulty': difficulty,
    'cardCount': cardCount,
    'cards': cards.map((c) => c.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'isGenerating': isGenerating,
  };

  factory FlashcardSet.fromJson(Map<String, dynamic> j) => FlashcardSet(
    id: j['id'] as String,
    documentId: j['documentId'] as String,
    documentTitle: j['documentTitle'] as String? ?? '',
    difficulty: j['difficulty'] as String? ?? 'medium',
    cardCount: j['cardCount'] as int? ?? 0,
    cards: (j['cards'] as List<dynamic>? ?? [])
        .map((c) => FlashCard.fromJson(c as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(j['createdAt'] as String),
    isGenerating: j['isGenerating'] as bool? ?? false,
  );
}

// ─── FlashcardRepository ─────────────────────────────────────────────────────

class FlashcardRepository extends Notifier<int> {
  static const _kPrefsKey = 'flashcard_sets_v1';

  final Map<String, List<FlashcardSet>> _setsByDoc = {};

  @override
  int build() {
    _load();
    return 0;
  }

  List<FlashcardSet> setsForDoc(String documentId) =>
      List<FlashcardSet>.unmodifiable(_setsByDoc[documentId] ?? []);

  Future<void> addSet(FlashcardSet set) async {
    final list = _setsByDoc.putIfAbsent(set.documentId, () => []);
    list.insert(0, set);
    await _save();
    state = state + 1;
  }

  Future<void> updateSet(FlashcardSet set) async {
    final list = _setsByDoc[set.documentId];
    if (list == null) return;
    final idx = list.indexWhere((s) => s.id == set.id);
    if (idx >= 0) {
      list[idx] = set;
      await _save();
      state = state + 1;
    }
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefsKey);
      if (raw == null) return;
      final List<dynamic> all = jsonDecode(raw) as List<dynamic>;
      for (final item in all) {
        final s = FlashcardSet.fromJson(item as Map<String, dynamic>);
        _setsByDoc.putIfAbsent(s.documentId, () => []).add(s);
      }
      state = state + 1;
    } catch (e) {
      debugPrint('FlashcardRepository load error: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final all = _setsByDoc.values
          .expand((list) => list)
          .map((s) => s.toJson())
          .toList();
      await prefs.setString(_kPrefsKey, jsonEncode(all));
    } catch (e) {
      debugPrint('FlashcardRepository save error: $e');
    }
  }
}

// Global provider
final flashcardRepositoryProvider = NotifierProvider<FlashcardRepository, int>(
  FlashcardRepository.new,
);
