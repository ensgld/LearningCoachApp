import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learning_coach/shared/models/models.dart';

// ─── QuizAttempt ─────────────────────────────────────────────────────────────

class QuizAttempt {
  final DateTime date;
  final int correctCount;
  final int total;

  const QuizAttempt({
    required this.date,
    required this.correctCount,
    required this.total,
  });

  double get score => total > 0 ? correctCount / total : 0;
  int get percent => (score * 100).round();

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'correctCount': correctCount,
        'total': total,
      };

  factory QuizAttempt.fromJson(Map<String, dynamic> j) => QuizAttempt(
        date: DateTime.parse(j['date'] as String),
        correctCount: j['correctCount'] as int,
        total: j['total'] as int,
      );
}

// ─── QuizSession ──────────────────────────────────────────────────────────────

class QuizSession {
  final String id;
  final String documentId;
  final String documentTitle;
  final String difficulty;
  final int questionCount;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  final List<QuizAttempt> attempts;
  final bool isGenerating;

  QuizSession({
    required this.id,
    required this.documentId,
    required this.documentTitle,
    required this.difficulty,
    required this.questionCount,
    required this.questions,
    required this.createdAt,
    this.attempts = const [],
    this.isGenerating = false,
  });

  QuizSession copyWith({
    String? id,
    String? documentId,
    String? documentTitle,
    String? difficulty,
    int? questionCount,
    List<QuizQuestion>? questions,
    DateTime? createdAt,
    List<QuizAttempt>? attempts,
    bool? isGenerating,
  }) {
    return QuizSession(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 'easy': return 'Kolay';
      case 'hard': return 'Zor';
      default: return 'Orta';
    }
  }

  QuizSession withAttempt(QuizAttempt attempt) => copyWith(
        attempts: [...attempts, attempt],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'documentId': documentId,
        'documentTitle': documentTitle,
        'difficulty': difficulty,
        'questionCount': questionCount,
        'questions': questions.map((q) => {
              'question': q.question,
              'options': q.options,
              'answer': q.answer,
              'explanation': q.explanation,
            }).toList(),
        'createdAt': createdAt.toIso8601String(),
        'attempts': attempts.map((a) => a.toJson()).toList(),
        'isGenerating': isGenerating,
      };

  factory QuizSession.fromJson(Map<String, dynamic> j) => QuizSession(
        id: j['id'] as String,
        documentId: j['documentId'] as String,
        documentTitle: j['documentTitle'] as String? ?? '',
        difficulty: j['difficulty'] as String? ?? 'medium',
        questionCount: j['questionCount'] as int? ?? 0,
        questions: (j['questions'] as List<dynamic>? ?? [])
            .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(j['createdAt'] as String),
        attempts: (j['attempts'] as List<dynamic>? ?? [])
            .map((a) => QuizAttempt.fromJson(a as Map<String, dynamic>))
            .toList(),
        isGenerating: j['isGenerating'] as bool? ?? false,
      );
}

// ─── Riverpod Notifier ────────────────────────────────────────────────────────

class QuizRepository extends Notifier<int> {
  static const _kPrefsKey = 'quiz_sessions_v1';

  final Map<String, List<QuizSession>> _sessionsByDoc = {};

  @override
  int build() {
    _load();
    return 0;
  }

  List<QuizSession> sessionsForDoc(String documentId) =>
      List<QuizSession>.unmodifiable(_sessionsByDoc[documentId] ?? []);

  Future<void> addSession(QuizSession session) async {
    final list = _sessionsByDoc.putIfAbsent(session.documentId, () => []);
    list.insert(0, session);
    await _save();
    state = state + 1;
  }

  Future<void> updateSession(QuizSession session) async {
    final list = _sessionsByDoc[session.documentId];
    if (list == null) return;
    final idx = list.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      list[idx] = session;
      await _save();
      state = state + 1;
    }
  }

  Future<void> recordAttempt({
    required String sessionId,
    required String documentId,
    required int correctCount,
    required int total,
  }) async {
    final list = _sessionsByDoc[documentId];
    if (list == null) return;
    final idx = list.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return;
    final attempt = QuizAttempt(
      date: DateTime.now(),
      correctCount: correctCount,
      total: total,
    );
    list[idx] = list[idx].withAttempt(attempt);
    await _save();
    state = state + 1;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefsKey);
      if (raw == null) return;
      final List<dynamic> all = jsonDecode(raw) as List<dynamic>;
      for (final item in all) {
        final s = QuizSession.fromJson(item as Map<String, dynamic>);
        _sessionsByDoc.putIfAbsent(s.documentId, () => []).add(s);
      }
      state = state + 1;
    } catch (e) {
      debugPrint('QuizRepository load error: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final all = _sessionsByDoc.values
          .expand((list) => list)
          .map((s) => s.toJson())
          .toList();
      await prefs.setString(_kPrefsKey, jsonEncode(all));
    } catch (e) {
      debugPrint('QuizRepository save error: $e');
    }
  }
}

// Global provider (Riverpod 3.x NotifierProvider)
final quizRepositoryProvider = NotifierProvider<QuizRepository, int>(
  QuizRepository.new,
);
