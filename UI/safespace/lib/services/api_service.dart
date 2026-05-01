import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://alisakr9997-safespace.hf.space/api/v1";

  // Connects to the main API for analyzing DASS-42 and text, which then auto-saves to PostgreSQL
  static Future<Map<String, dynamic>> analyzeMentalHealth(String text, List<int> surveyAnswers) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": text,
          "survey_answers": surveyAnswers
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to analyze: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }

  // Connects to the secure Chatbot Proxy
  static Future<String> chatWithAi(String message, {String sessionId = "default"}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "session_id": sessionId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"];
      } else {
        throw Exception("Failed to chat: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Chat API Error: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/analyses/history'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('API History Error: $e');
      return [];
    }
  }
}
