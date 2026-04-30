import 'package:flutter/material.dart';

class AppState {
  static Map<String, int>? lastDassResults;
  static String? userPassword;

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
