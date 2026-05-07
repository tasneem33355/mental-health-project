import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/app_state.dart';

class ApiService {
  static const String baseUrl = "https://alisakr9997-safespace.hf.space/api/v1";

  // --- AUTH ---

  /// Register a new user account
  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body["detail"] ?? "Signup failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("$e");
    }
  }

  /// Login with email and password
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body["detail"] ?? "Login failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("$e");
    }
  }

  // --- ANALYSIS ---

  /// Connects to the main API for analyzing DASS-42 and text, which then auto-saves to PostgreSQL
  static Future<Map<String, dynamic>> analyzeMentalHealth(String text, List<int> surveyAnswers) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": text,
          "survey_answers": surveyAnswers,
          "user_id": AppState.userId,
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

  // --- CHAT ---

  /// Connects to the secure Chatbot Proxy
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

  // --- HISTORY ---

  static Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      String url = '$baseUrl/analyses/history';
      if (AppState.userId != null) {
        url += '?user_id=${AppState.userId}';
      }
      final response = await http.get(Uri.parse(url));
      
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

  // --- CHECKINS ---

  static Future<Map<String, dynamic>> createCheckin({
    required int mood,
    required int sleep,
    required double energy,
    String? clientTs,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkin'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mood": mood,
          "sleep": sleep,
          "energy": energy,
          "user_id": AppState.userId,
          if (clientTs != null) "client_ts": clientTs,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to save check-in: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Check-in API Error: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getCheckinHistory() async {
    try {
      String url = '$baseUrl/checkin/history';
      if (AppState.userId != null) {
        url += '?user_id=${AppState.userId}';
      }
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- JOURNAL ---

  static Future<Map<String, dynamic>> createJournalEntry({
    required String content,
    String? clientTs,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/journal'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "content": content,
          "user_id": AppState.userId,
          if (clientTs != null) "client_ts": clientTs,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to save journal: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Journal API Error: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getJournalHistory() async {
    try {
      String url = '$baseUrl/journal/history';
      if (AppState.userId != null) {
        url += '?user_id=${AppState.userId}';
      }
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> updateJournalEntry({
    required int entryId,
    required String content,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/journal/$entryId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"content": content}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to update journal: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Journal API Error: $e");
    }
  }

  static Future<void> deleteJournalEntry({
    required int entryId,
  }) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/journal/$entryId'));
      if (response.statusCode != 200) {
        throw Exception("Failed to delete journal: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Journal API Error: $e");
    }
  }
}
