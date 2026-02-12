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

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      progress: double.tryParse(json['progress'].toString()) ?? 0.0,
      status: json['status'] == 'completed'
          ? GoalStatus.completed
          : GoalStatus.active,
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((t) => GoalTask.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'progress': progress,
      'status': status == GoalStatus.completed ? 'completed' : 'active',
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, title, description, progress, status, tasks];
}

class GoalTask extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  GoalTask({String? id, required this.title, this.isCompleted = false})
    : id = id ?? uuid.v4();

  GoalTask copyWith({String? title, bool? isCompleted}) {
    return GoalTask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory GoalTask.fromJson(Map<String, dynamic> json) {
    return GoalTask(
      id: json['id'] as String?,
      title: json['title'] as String,
      isCompleted: (json['is_completed'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'is_completed': isCompleted};
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}

// --- Study Session ---

class StudySession extends Equatable {
  final String id;
  final String goalId;
  final int durationMinutes;
  final DateTime startTime;
  final int? actualDurationSeconds;
  final int? quizScore;

  StudySession({
    String? id,
    required this.goalId,
    required this.durationMinutes,
    required this.startTime,
    this.actualDurationSeconds,
    this.quizScore,
  }) : id = id ?? uuid.v4();

  @override
  List<Object?> get props => [
    id,
    goalId,
    durationMinutes,
    startTime,
    actualDurationSeconds,
    quizScore,
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
  final double processingProgress;

  Document({
    String? id,
    required this.title,
    this.summary = '',
    this.status = DocStatus.processing,
    DateTime? uploadedAt,
    this.processingProgress = 0,
  }) : id = id ?? uuid.v4(),
       uploadedAt = uploadedAt ?? DateTime.now();

  factory Document.fromJson(Map<String, dynamic> json) {
    DocStatus status = DocStatus.processing;
    if (json['status'] == 'ready') status = DocStatus.ready;
    if (json['status'] == 'failed') status = DocStatus.failed;

    final progressRaw = json['processing_progress'];
    final progress = progressRaw is num ? progressRaw.toDouble() : 0.0;

    return Document(
      id: json['id'] as String?,
      title: json['title'] as String,
      summary: json['summary'] as String? ?? '',
      status: status,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      processingProgress: progress,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    summary,
    status,
    uploadedAt,
    processingProgress,
  ];
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
