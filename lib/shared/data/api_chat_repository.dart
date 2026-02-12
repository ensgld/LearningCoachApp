import 'package:learning_coach/shared/services/api_service.dart';

class ApiChatRepository {
  final ApiService _apiService;

  ApiChatRepository(this._apiService);

  Future<String> sendMessage(String message) async {
    return _apiService.sendChatMessage(message);
  }
}
