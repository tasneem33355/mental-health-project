import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AppState {
  static Map<String, int>? lastDassResults;
  static String? userPassword;
  static String? userEmail;
  static int? userId;
  static String? userName;
  static DateTime? lastCheckInDate;
  static List<MoodRecord> moodHistory = [];
  static List<Goal> goals = [];
  static List<JournalEntry> journalEntries = [];

  // --- Persistence Keys ---
  static String get _keyMoodHistory => 'mood_history_$userId';
  static String get _keyGoals => 'goals_$userId';
  static String get _keyLastCheckIn => 'last_check_in_$userId';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPassword = 'user_password';

  /// Initialize app state from SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Restore user info
    userId = prefs.getInt(_keyUserId);
    userEmail = prefs.getString(_keyUserEmail);
    userName = prefs.getString(_keyUserName);
    userPassword = prefs.getString(_keyUserPassword);

    await loadUserData(isFirstLaunch: true);
  }

  static Future<void> loadUserData({bool isFirstLaunch = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Restore last check-in date
    final checkInStr = prefs.getString(_keyLastCheckIn);
    if (checkInStr != null) {
      lastCheckInDate = DateTime.tryParse(checkInStr);
    } else {
      lastCheckInDate = null;
    }

    // Restore mood history
    final moodJson = prefs.getStringList(_keyMoodHistory);
    if (moodJson != null && moodJson.isNotEmpty) {
      moodHistory = moodJson.map((s) => MoodRecord.fromJson(jsonDecode(s))).toList();
    } else {
      // Pre-fill demo data only on first launch if empty
      if (isFirstLaunch && userId == null) {
        moodHistory = [
          MoodRecord(date: DateTime.now().subtract(const Duration(days: 6)), stress: 1, energy: 0.8, sleep: 4),
          MoodRecord(date: DateTime.now().subtract(const Duration(days: 5)), stress: 2, energy: 0.6, sleep: 3),
          MoodRecord(date: DateTime.now().subtract(const Duration(days: 4)), stress: 3, energy: 0.4, sleep: 2),
          MoodRecord(date: DateTime.now().subtract(const Duration(days: 3)), stress: 2, energy: 0.7, sleep: 3),
          MoodRecord(date: DateTime.now().subtract(const Duration(days: 2)), stress: 4, energy: 0.3, sleep: 1),
          MoodRecord(date: DateTime.now().subtract(const Duration(days: 1)), stress: 1, energy: 0.9, sleep: 4),
        ];
      } else {
        moodHistory = [];
      }
    }

    // Restore goals
    final goalsJson = prefs.getStringList(_keyGoals);
    if (goalsJson != null) {
      goals = goalsJson.map((s) => Goal.fromJson(jsonDecode(s))).toList();
    } else {
      goals = [];
    }

    // Journal entries are loaded from API on demand
  }

  // --- Save helpers ---
  static Future<void> _saveMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = moodHistory.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_keyMoodHistory, jsonList);
  }

  static Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = goals.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList(_keyGoals, jsonList);
  }


  static Future<void> saveUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) await prefs.setInt(_keyUserId, userId!);
    if (userEmail != null) await prefs.setString(_keyUserEmail, userEmail!);
    if (userName != null) await prefs.setString(_keyUserName, userName!);
    if (userPassword != null) await prefs.setString(_keyUserPassword, userPassword!);
    await loadUserData(); // Reload user-specific data after changing identity
  }

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    userId = null;
    userEmail = null;
    userName = null;
    userPassword = null;
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserPassword);
    
    // Clear in-memory user data
    lastCheckInDate = null;
    moodHistory = [];
    goals = [];
    journalEntries = [];
  }

  static bool get isLoggedIn => userId != null && userEmail != null;

  static bool get canCheckIn {
    if (lastCheckInDate == null) return true;
    final now = DateTime.now();
    return lastCheckInDate!.day != now.day || 
           lastCheckInDate!.month != now.month || 
           lastCheckInDate!.year != now.year;
  }

  static Future<void> addMoodRecord(int stress, double energy, int sleep) async {
    moodHistory.add(MoodRecord(
      date: DateTime.now(),
      stress: stress,
      energy: energy,
      sleep: sleep,
    ));
    lastCheckInDate = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastCheckIn, lastCheckInDate!.toIso8601String());
    await _saveMoodHistory();

    if (userId != null) {
      try {
        await ApiService.createCheckin(
          mood: stress,
          sleep: sleep,
          energy: energy,
          clientTs: lastCheckInDate!.toUtc().toIso8601String(),
        );
      } catch (_) {
        // Ignore network failures; local state is already saved.
      }
    }
  }

  static Future<void> addGoal(String title, DateTime? deadline) async {
    goals.add(Goal(title: title, deadline: deadline));
    await _saveGoals();
  }

  static Future<void> removeGoal(Goal goal) async {
    goals.remove(goal);
    await _saveGoals();
  }

  static Future<void> updateGoals() async {
    await _saveGoals();
  }

  static Future<void> addJournalEntry(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    await ApiService.createJournalEntry(
      content: trimmed,
      clientTs: DateTime.now().toUtc().toIso8601String(),
    );
  }

  static Future<void> refreshJournalEntries() async {
    final data = await ApiService.getJournalHistory();
    journalEntries = data
        .where((item) => item['created_at'] != null)
        .map((item) {
          final date = DateTime.tryParse(item['created_at'].toString());
          if (date == null) return null;
          final content = (item['content'] ?? '').toString();
          final lines = content.split('\n');
          final title = lines.isNotEmpty && lines.first.trim().isNotEmpty
              ? lines.first.trim()
              : 'Journal Entry';
          final body = lines.length > 2 
              ? lines.sublist(2).join('\n') 
              : (lines.length > 1 ? lines.sublist(1).join('\n') : '');
          final preview = body.length > 120 ? '${body.substring(0, 120)}...' : body;
          return JournalEntry(
            id: (item['id'] as num?)?.toInt(),
            date: date.toLocal(),
            title: title,
            preview: preview,
            content: content,
          );
        })
        .whereType<JournalEntry>()
        .toList();
  }

  static String getMoodStatus() {
    if (lastDassResults == null) return 'Not Assessed';
    
    int d = lastDassResults!['Depression'] ?? 0;
    int a = lastDassResults!['Anxiety'] ?? 0;
    int s = lastDassResults!['Stress'] ?? 0;

    if (s > 25 || a > 14 || d > 20) return 'Struggling';
    if (s > 18 || a > 9 || d > 13) return 'Unbalanced';
    return 'Stable';
  }
}

class MoodRecord {
  final DateTime date;
  final int stress;
  final double energy;
  final int sleep;

  MoodRecord({
    required this.date,
    required this.stress,
    required this.energy,
    required this.sleep,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'stress': stress,
    'energy': energy,
    'sleep': sleep,
  };

  factory MoodRecord.fromJson(Map<String, dynamic> json) => MoodRecord(
    date: DateTime.parse(json['date']),
    stress: json['stress'],
    energy: (json['energy'] as num).toDouble(),
    sleep: json['sleep'],
  );
}

class Goal {
  final String title;
  final DateTime? deadline;
  bool isDone;

  Goal({required this.title, this.deadline, this.isDone = false});

  Map<String, dynamic> toJson() => {
    'title': title,
    'deadline': deadline?.toIso8601String(),
    'isDone': isDone,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    title: json['title'],
    deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    isDone: json['isDone'] ?? false,
  );
}

class JournalEntry {
  final int? id;
  final DateTime date;
  final String title;
  final String preview;
  final String content;

  JournalEntry({
    this.id,
    required this.date,
    required this.title,
    required this.preview,
    required this.content,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'] as int?,
    date: DateTime.parse(json['date']),
    title: json['title'],
    preview: json['preview'],
    content: json['content'],
  );
}
