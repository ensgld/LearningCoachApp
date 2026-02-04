import 'package:dio/dio.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/services/api_service.dart';

class ApiGoalRepository {
  final ApiService _apiService;

  ApiGoalRepository(this._apiService);

  Dio get _dio => _apiService.dio;

  Future<List<Goal>> getGoals() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/goals');
      final data = response.data!['goals'] as List<dynamic>;
      return data
          .map((json) => Goal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Goal> createGoal({
    required String title,
    String? description,
    List<String>? tasks,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/goals',
        data: {
          'title': title,
          'description': description,
          'tasks': tasks?.map((t) => {'title': t}).toList(),
        },
      );
      return Goal.fromJson(response.data!['goal'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Goal> updateGoal(Goal goal) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/goals/${goal.id}',
        data: {
          'title': goal.title,
          'description': goal.description,
          'status': goal.status == GoalStatus.completed
              ? 'completed'
              : 'active',
        },
      );
      return Goal.fromJson(response.data!['goal'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _dio.delete<void>('/goals/$goalId');
    } catch (e) {
      rethrow;
    }
  }

  // Task Management
  Future<Goal> addTask(String goalId, String title) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/goals/$goalId/tasks',
        data: {'title': title},
      );
      return Goal.fromJson(response.data!['goal'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Goal> updateTask(String goalId, GoalTask task) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/goals/$goalId/tasks/${task.id}',
        data: {'title': task.title, 'isCompleted': task.isCompleted},
      );
      return Goal.fromJson(response.data!['goal'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Goal> deleteTask(String goalId, String taskId) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/goals/$goalId/tasks/$taskId',
      );
      return Goal.fromJson(response.data!['goal'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
