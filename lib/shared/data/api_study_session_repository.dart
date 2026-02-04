import 'package:dio/dio.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/services/api_service.dart';

class ApiStudySessionRepository {
  final ApiService _apiService;

  ApiStudySessionRepository(this._apiService);

  Dio get _dio => _apiService.dio;

  Future<StudySession> createSession({
    required String goalId,
    required int durationMinutes,
    int? actualDurationSeconds,
    int? quizScore,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/study-sessions',
        data: {
          'goalId': goalId,
          'durationMinutes': durationMinutes,
          'actualDurationSeconds': actualDurationSeconds,
          'quizScore': quizScore,
        },
      );

      final data = response.data!['session'] as Map<String, dynamic>;

      return StudySession(
        id: data['id'] as String?,
        goalId: data['goal_id'] as String,
        durationMinutes: data['duration_minutes'] as int,
        startTime: DateTime.parse(data['start_time'] as String),
        actualDurationSeconds: data['actual_duration_seconds'] as int?,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StudySession>> getSessions() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/study-sessions');
      final list = response.data!['sessions'] as List<dynamic>;

      return list.map((json) {
        final data = json as Map<String, dynamic>;
        return StudySession(
          id: data['id'] as String?,
          goalId: data['goal_id'] as String,
          durationMinutes: data['duration_minutes'] as int,
          startTime: DateTime.parse(data['start_time'] as String),
          actualDurationSeconds: data['actual_duration_seconds'] as int?,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
