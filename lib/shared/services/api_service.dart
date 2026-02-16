  bool get isLoggedIn => _accessToken != null;

  //--------------  LLM BACKEND --------------//

  static String get baseUrlLLM {
    // 1. Önce .env dosyasında tanımlı mı diye bakıyoruz
    final envUrl = dotenv.env['LLM_BASE_URL'];
    final debugModeLLM = dotenv.env['DEBUG_MODE_LLM'];

    if (debugModeLLM == 'true') {
      return 'http://127.0.0.1:8000';
    }

    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    // 2. Eğer .env boşsa veya okunamazsa, senin sabit Windows sunucu IP'ni kullanıyoruz.
    // Not: Sunucu farklı bilgisayarda olduğu için 'localhost' veya '10.0.2.2' işe yaramaz.
    // Doğrudan o bilgisayarın ağ adresine gitmeliyiz.
    return 'http://172.24.0.198:8000';
  }

  Future<Map<String, dynamic>> sendChatMessage(
    String message, {
    String? threadId,
  }) async {
    final response = await _dio.post(
      '/chat',
      data: {'message': message, if (threadId != null) 'threadId': threadId},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getChatHistory({String? threadId}) async {
    final response = await _dio.get(
      '/chat/history',
      queryParameters: threadId != null ? {'threadId': threadId} : null,
    );
    return response.data as Map<String, dynamic>;
  }
}
