import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_state.dart';
import '../localization.dart';

class RecommendationScreen extends StatelessWidget {
  final String timeOfDay;

  const RecommendationScreen({super.key, required this.timeOfDay});

  List<Map<String, dynamic>> _getRecommendations() {
    final results = AppState.lastDassResults;
    if (results == null) {
      if (timeOfDay == 'Morning') {
        return [
          {'title': 'Sunlight Exposure'.tr, 'desc': 'Open your curtains or step outside for 5 mins to boost serotonin.'.tr, 'icon': '☀️'},
          {'title': 'Healthy Breakfast'.tr, 'desc': 'Fuel your brain with a nutritious meal to start strong.'.tr, 'icon': '🍳'},
          {'title': 'Hydrate'.tr, 'desc': 'Drink a large glass of water to wake up your body.'.tr, 'icon': '💧'},
        ];
      }
      return [
        {'title': 'Digital Detox'.tr, 'desc': 'Put away screens 30 mins before sleep to reduce mental noise.'.tr, 'icon': '📵'},
        {'title': 'Warm Bath/Shower'.tr, 'desc': 'Let warm water wash away the day\'s fatigue.'.tr, 'icon': '🚿'},
        {'title': 'Warm Tea'.tr, 'desc': 'A caffeine-free herbal tea can help signal your body it\'s time to rest.'.tr, 'icon': '🍵'},
      ];
    }

    final int d = results['Depression'] ?? 0;
    final int a = results['Anxiety'] ?? 0;
    final int s = results['Stress'] ?? 0;
    final List<Map<String, dynamic>> recs = [];

    if (timeOfDay == 'Morning') {
      if (s > 15) {
        recs.add({'title': 'Calm Breathing'.tr, 'desc': 'Start with 5 mins of box breathing to lower your stress baseline.'.tr, 'icon': '🌬️'});
        recs.add({'title': 'Morning Journaling'.tr, 'desc': 'Write out what\'s on your mind to clear your head before starting the day.'.tr, 'icon': '📓'});
      } else {
        recs.add({'title': 'Sunlight Exposure'.tr, 'desc': 'Open your curtains or step outside for 5 mins to boost serotonin.'.tr, 'icon': '☀️'});
        recs.add({'title': 'Healthy Breakfast'.tr, 'desc': 'Fuel your brain with a nutritious meal to start strong.'.tr, 'icon': '🍳'});
      }

      if (a > 10) {
        recs.add({'title': 'Daily Intention'.tr, 'desc': 'Set one small, manageable goal for today to feel in control.'.tr, 'icon': '📝'});
        recs.add({'title': 'Mindful Coffee/Tea'.tr, 'desc': 'Sip your morning drink slowly, focusing only on the taste and warmth.'.tr, 'icon': '☕'});
      }

      if (d > 10) {
        recs.add({'title': 'Physical Movement'.tr, 'desc': 'Try a 2-minute stretch to help wake up your body and mind.'.tr, 'icon': '🏃'});
        recs.add({'title': 'Gentle Start'.tr, 'desc': 'Listen to your favorite uplifting song while getting ready.'.tr, 'icon': '🎵'});
      }
    } else {
      if (s > 15) {
        recs.add({'title': 'Digital Detox'.tr, 'desc': 'Put away screens 30 mins before sleep to reduce mental noise.'.tr, 'icon': '📵'});
        recs.add({'title': 'Progressive Muscle Relaxation'.tr, 'desc': 'Tense and relax each muscle group slowly to release built-up tension.'.tr, 'icon': '🧘'});
      } else {
        recs.add({'title': 'Warm Bath/Shower'.tr, 'desc': 'Let warm water wash away the day\'s fatigue.'.tr, 'icon': '🚿'});
      }

      if (a > 10) {
        recs.add({'title': 'Guided Grounding'.tr, 'desc': 'Focus on 5 things you can see and 4 things you can touch.'.tr, 'icon': '⚓'});
        recs.add({'title': 'White Noise / Nature Sounds'.tr, 'desc': 'Play rain or ocean sounds to soothe your anxious thoughts.'.tr, 'icon': '🌊'});
      }

      if (d > 10) {
        recs.add({'title': 'Positive Reflection'.tr, 'desc': 'Note down one thing that went better than expected today.'.tr, 'icon': '🌟'});
        recs.add({'title': 'Self-Compassion'.tr, 'desc': 'Remind yourself that you did your best today, and that is enough.'.tr, 'icon': '❤️'});
      }

      recs.add({'title': 'Warm Tea'.tr, 'desc': 'A caffeine-free herbal tea can help signal your body it\'s time to rest.'.tr, 'icon': '🍵'});
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
        title: Text('$timeOfDay Recommendations'.tr, style: TextStyle(color: AppTheme.textWhite)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personalized for you'.tr, style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text('Based on your recent assessment, we suggest these activities:'.tr, style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
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
                              Text(item['title'], style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(item['desc'], style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
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
