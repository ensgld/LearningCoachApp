import 'package:dio/dio.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/services/api_service.dart';

class ApiStatsRepository {
  final ApiService _apiService;

  ApiStatsRepository(this._apiService);

  Dio get _dio => _apiService.dio;

  Future<UserStats> getUserStats() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/user/stats');
      final data = response.data!['stats'] as Map<String, dynamic>;

      // Map API response to UserStats model
      // API returns snake_case or camelCase depending on PG driver config but service returns manually constructed obj
      // Service returns { currentLevel, currentXP, totalGold, avatarStage } (camelCase)

      return UserStats(
        currentLevel: data['currentLevel'] as int,
        currentXP: data['currentXP'] as int,
        totalGold: data['totalGold'] as int,
        stage: _parseStage(data['avatarStage'] as String),
        equippedItems: const {}, // Not implemented in backend yet
        purchasedItemIds: const [], // Not implemented in backend yet
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/user/progress');
      return response.data!['progress'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DailyStats>> getDailyStats() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/user/daily');
      final list = response.data!['dailyStats'] as List<dynamic>;
      return list
          .map((e) => DailyStats.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  AvatarStage _parseStage(String stage) {
    switch (stage) {
      case 'seed':
        return AvatarStage.seed;
      case 'sprout':
        return AvatarStage.sprout;
      case 'bloom':
        return AvatarStage.bloom;
      case 'tree':
        return AvatarStage.tree;
      case 'forest':
        return AvatarStage.forest;
      default:
        return AvatarStage.seed;
    }
  }
}

class DailyStats {
  final String date;
  final int minutes;
  final int sessions;

  DailyStats({
    required this.date,
    required this.minutes,
    required this.sessions,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'] as String,
      minutes: json['minutes'] as int,
      sessions: json['sessions'] as int,
    );
  }
}
