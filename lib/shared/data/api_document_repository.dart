import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:learning_coach/shared/models/models.dart';
import 'package:learning_coach/shared/services/api_service.dart';

class ApiDocumentRepository {
  final ApiService _apiService;

  ApiDocumentRepository(this._apiService);

  Dio get _dio => _apiService.dio;

  Future<List<Document>> getDocuments() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/documents');
      final data = response.data!['documents'] as List<dynamic>;
      return data
          .map((json) => Document.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list on error for now or rethrow
      rethrow;
    }
  }

  Future<Document> uploadDocument(File file, {String? title}) async {
    try {
      String fileName = file.path.split('/').last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'title': title ?? fileName,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/documents',
        data: formData,
      );

      return Document.fromJson(
        response.data!['document'] as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Document> uploadDocumentBytes(
    Uint8List bytes,
    String fileName, {
    String? title,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
        'title': title ?? fileName,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/documents',
        data: formData,
      );

      return Document.fromJson(
        response.data!['document'] as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await _dio.delete<void>('/documents/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<CoachMessage> chatWithDocument(
    String documentId,
    String message,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/documents/$documentId/chat',
        data: {'message': message},
      );

      final data = response.data!;
      final sourcesData = data['sources'] as List<dynamic>?;

      final sources = sourcesData
          ?.map(
            (s) => Source(
              docTitle: s['docTitle'] as String? ?? '',
              excerpt: s['excerpt'] as String? ?? '',
              pageLabel: s['pageLabel'] as String? ?? '',
            ),
          )
          .toList();

      return CoachMessage(
        text: data['answer'] as String? ?? '',
        isUser: false,
        sources: sources,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CoachMessage>> getDocumentChatHistory(String documentId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/documents/$documentId/chat/history',
      );

      final data = response.data!['messages'] as List<dynamic>? ?? [];

      return data.map((item) {
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
    } catch (e) {
      rethrow;
    }
  }
}
