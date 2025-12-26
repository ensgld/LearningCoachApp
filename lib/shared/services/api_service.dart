import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  Future<String> sendChatMessage(String message) async {
    try {
      final url = Uri.parse('$baseUrl/chat');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // DÜZELTME BURADA: 'as String' ekledik
        return data['answer'] as String;
      } else {
        throw Exception('Server hatası: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("API Hatası: $e");
      // Hata durumunda boş string dönmek yerine hatayı fırlatalım ki UI yakalasın
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
