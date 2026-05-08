import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_state.dart';

class RecommendationScreen extends StatelessWidget {
  final String timeOfDay; // 'Morning' or 'Evening'

  const RecommendationScreen({super.key, required this.timeOfDay});

  List<Map<String, dynamic>> _getRecommendations() {
    final results = AppState.lastDassResults;
    if (results == null) {
      return [
        {'title': 'General Wellness', 'desc': 'Take a moment to breathe and center yourself.', 'icon': '🧘'},
        {'title': 'Hydrate', 'desc': 'A glass of water can help refresh your mind.', 'icon': '💧'},
      ];
    }

    int d = results['Depression'] ?? 0;
    int a = results['Anxiety'] ?? 0;
    int s = results['Stress'] ?? 0;

    List<Map<String, dynamic>> recs = [];

    if (timeOfDay == 'Morning') {
      if (s > 15) {
        recs.add({'title': 'Calm Breathing', 'desc': 'Start with 5 mins of box breathing to lower your stress baseline.', 'icon': '🌬️'});
      } else {
        recs.add({'title': 'Sunlight Exposure', 'desc': 'Open your curtains or step outside for 5 mins to boost serotonin.', 'icon': '☀️'});
      }

      if (a > 10) {
        recs.add({'title': 'Daily Intention', 'desc': 'Set one small, manageable goal for today to feel in control.', 'icon': '📝'});
      }

      if (d > 10) {
        recs.add({'title': 'Physical Movement', 'desc': 'Try a 2-minute stretch to help wake up your body and mind.', 'icon': '🏃'});
      }
    } else { // Evening
      if (s > 15 || a > 10) {
        recs.add({'title': 'Digital Detox', 'desc': 'Put away screens 30 mins before sleep to reduce mental noise.', 'icon': '📵'});
        recs.add({'title': 'Guided Grounding', 'desc': 'Focus on 5 things you can see and 4 things you can touch.', 'icon': '⚓'});
      }

      if (d > 10) {
        recs.add({'title': 'Positive Reflection', 'desc': 'Note down one thing that went better than expected today.', 'icon': '🌟'});
      }

      recs.add({'title': 'Warm Tea', 'desc': 'A caffeine-free herbal tea can help signal your body it\'s time to rest.', 'icon': '🍵'});
    }

    return recs;
  }

  @override
  Widget build(BuildContext context) {
    final recs = _getRecommendations();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        title: Text('$timeOfDay Recommendations', style: const TextStyle(color: AppTheme.textWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalized for you',
              style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Based on your recent assessment, we suggest these activities:',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: recs.length,
                itemBuilder: (context, index) {
                  final item = recs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.textDimmed.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Text(item['icon'], style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['desc'],
                                style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
