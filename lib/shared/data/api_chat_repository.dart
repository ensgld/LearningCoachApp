import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/services/api_service.dart';

class ChatHistoryResult {
  final String? threadId;
  final List<CoachMessage> messages;

  ChatHistoryResult({required this.threadId, required this.messages});
}

class ChatSendResult {
  final String answer;
  final String? threadId;

  ChatSendResult({required this.answer, required this.threadId});
}

class ApiChatRepository {
  final ApiService _apiService;

  ApiChatRepository(this._apiService);

  Future<ChatSendResult> sendMessage(String message, {String? threadId}) async {
    final data = await _apiService.sendChatMessage(message, threadId: threadId);

    return ChatSendResult(
      answer: data['answer'] as String? ?? '',
      threadId: data['threadId'] as String?,
    );
  }

  Future<ChatHistoryResult> getHistory({String? threadId}) async {
    final data = await _apiService.getChatHistory(threadId: threadId);
    final rawMessages = data['messages'] as List<dynamic>? ?? [];

    final messages = rawMessages.map((item) {
      final json = item as Map<String, dynamic>;
      final timestampRaw = json['timestamp'];
      DateTime? timestamp;
      if (timestampRaw is String) {
        timestamp = DateTime.tryParse(timestampRaw);
      }

      final sourcesRaw = json['sources'] as List<dynamic>?;
      final sources = sourcesRaw
          ?.map(
            (s) => Source(
              docTitle: s['docTitle'] as String? ?? '',
              excerpt: s['excerpt'] as String? ?? '',
              pageLabel: s['pageLabel'] as String? ?? '',
            ),
          )
          .toList();

      return CoachMessage(
        id: json['id'] as String?,
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        timestamp: timestamp,
        sources: sources,
      );
    }).toList();

    return ChatHistoryResult(
      threadId: data['threadId'] as String?,
      messages: messages,
    );
  }
}
