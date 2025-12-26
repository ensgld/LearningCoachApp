import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

export 'gamification_models.dart';

const uuid = Uuid();

// --- Goal & Tasks ---

enum GoalStatus { active, completed }

class Goal extends Equatable {
  final String id;
  final String title;
  final String description;
  final double progress; // 0.0 to 1.0
  final GoalStatus status;
  final List<GoalTask> tasks;

  Goal({
    String? id,
    required this.title,
    required this.description,
    this.progress = 0.0,
    this.status = GoalStatus.active,
    this.tasks = const [],
  }) : id = id ?? uuid.v4();

  @override
  List<Object?> get props => [id, title, description, progress, status, tasks];
}

class GoalTask extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  GoalTask({
    String? id,
    required this.title,
    this.isCompleted = false,
  }) : id = id ?? uuid.v4();
  
  GoalTask copyWith({bool? isCompleted}) {
    return GoalTask(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}

// --- Study Session & Quiz ---

class QuizQuestion extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  QuizQuestion({
    String? id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  }) : id = id ?? uuid.v4();

  @override
  List<Object?> get props => [id, question, options, correctOptionIndex];
}

class StudySession extends Equatable {
  final String id;
  final String goalId;
  final int durationMinutes;
  final DateTime startTime;
  final int? actualDurationSeconds;
  final int? quizScore;
  final List<QuizQuestion>? questions;
  final Map<String, int>? selectedAnswers; // questionId -> selectedOptionIndex

  StudySession({
    String? id,
    required this.goalId,
    required this.durationMinutes,
    required this.startTime,
    this.actualDurationSeconds,
    this.quizScore,
    this.questions,
    this.selectedAnswers,
  }) : id = id ?? uuid.v4();

  StudySession copyWith({
    int? actualDurationSeconds,
    int? quizScore,
    List<QuizQuestion>? questions,
    Map<String, int>? selectedAnswers,
  }) {
    return StudySession(
      id: id,
      goalId: goalId,
      durationMinutes: durationMinutes,
      startTime: startTime,
      actualDurationSeconds: actualDurationSeconds ?? this.actualDurationSeconds,
      quizScore: quizScore ?? this.quizScore,
      questions: questions ?? this.questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        goalId,
        durationMinutes,
        startTime,
        actualDurationSeconds,
        quizScore,
        questions,
        selectedAnswers,
      ];
}

// --- Document & Chat ---

enum DocStatus { processing, ready, failed }

class Document extends Equatable {
  final String id;
  final String title;
  final String summary;
  final DocStatus status;
  final DateTime uploadedAt;

  Document({
    String? id,
    required this.title,
    required this.summary,
    this.status = DocStatus.processing,
    DateTime? uploadedAt,
  }) : id = id ?? uuid.v4(),
       uploadedAt = uploadedAt ?? DateTime.now();

  @override
  List<Object?> get props => [id, title, summary, status, uploadedAt];
}

class CoachMessage extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Source>? sources;

  CoachMessage({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.sources,
  }) : id = id ?? uuid.v4(),
       timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [id, text, isUser, timestamp, sources];
}

class Source extends Equatable {
  final String docTitle;
  final String excerpt;
  final String pageLabel;

  const Source({
    required this.docTitle,
    required this.excerpt,
    required this.pageLabel,
  });

  @override
  List<Object?> get props => [docTitle, excerpt, pageLabel];
}

// --- Kaizen ---

class KaizenCheckin extends Equatable {
  final String id;
  final String didYesterday;
  final String blockedBy;
  final String doToday;
  final DateTime date;

  KaizenCheckin({
    String? id,
    required this.didYesterday,
    required this.blockedBy,
    required this.doToday,
    DateTime? date,
  }) : id = id ?? uuid.v4(),
       date = date ?? DateTime.now();

  @override
  List<Object?> get props => [id, didYesterday, blockedBy, doToday, date];
}
