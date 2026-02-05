import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // kIsWeb için

class ApiService {
  // Senin bilgisayarının sabit IP adresi
  static const String _serverIp = '172.24.0.198';

  static String get baseUrl {
    // Mobil cihaz (fiziksel veya emülatör) ve web fark etmeksizin
    // artık herkes bu ortak IP adresine gidecek.
    return 'http://$_serverIp:8000';
  }

  Future<String> sendChatMessage(String message) async {
    try {
      final url = Uri.parse('$baseUrl/chat');

      debugPrint("İstek gönderiliyor: $url"); // Log ekledik

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // UTF-8 önemli
          'Accept': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        // UTF-8 decode yaparak Türkçe karakter sorununu da çözüyoruz
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        return data['answer'] as String;
      } else {
        throw Exception(
          'Server hatası: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint("API Hatası: $e");
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
