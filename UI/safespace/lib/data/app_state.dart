import 'package:flutter/material.dart';

class AppState {
  static Map<String, int>? lastDassResults;
  static String? userPassword;
  static DateTime? lastCheckInDate;
  static List<MoodRecord> moodHistory = [
    // Pre-fill some data for demonstration
    MoodRecord(date: DateTime.now().subtract(const Duration(days: 6)), stress: 1, energy: 0.8, sleep: 4),
    MoodRecord(date: DateTime.now().subtract(const Duration(days: 5)), stress: 2, energy: 0.6, sleep: 3),
    MoodRecord(date: DateTime.now().subtract(const Duration(days: 4)), stress: 3, energy: 0.4, sleep: 2),
    MoodRecord(date: DateTime.now().subtract(const Duration(days: 3)), stress: 2, energy: 0.7, sleep: 3),
    MoodRecord(date: DateTime.now().subtract(const Duration(days: 2)), stress: 4, energy: 0.3, sleep: 1),
    MoodRecord(date: DateTime.now().subtract(const Duration(days: 1)), stress: 1, energy: 0.9, sleep: 4),
  ];

  static List<Goal> goals = [];

  static bool get canCheckIn {
    if (lastCheckInDate == null) return true;
    final now = DateTime.now();
    return lastCheckInDate!.day != now.day || 
           lastCheckInDate!.month != now.month || 
           lastCheckInDate!.year != now.year;
  }

  static void addMoodRecord(int stress, double energy, int sleep) {
    moodHistory.add(MoodRecord(
      date: DateTime.now(),
      stress: stress,
      energy: energy,
      sleep: sleep,
    ));
    lastCheckInDate = DateTime.now();
  }

  static void addGoal(String title, DateTime? deadline) {
    goals.add(Goal(title: title, deadline: deadline));
  }

  static void removeGoal(Goal goal) {
    goals.remove(goal);
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
}

class Goal {
  final String title;
  final DateTime? deadline;
  bool isDone;

  Goal({required this.title, this.deadline, this.isDone = false});
}
