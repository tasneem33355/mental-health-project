import 'package:flutter/material.dart';
import '../main.dart';
import 'article_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final Map<String, String> _challengeStatuses = {
    'Hydration Goal': 'Start',
    'Gratitude Journal': 'Start',
  };

  void _handleChallengeClick(String title) {
    setState(() {
      if (_challengeStatuses[title] == 'Start') {
        _challengeStatuses[title] = 'Done';
      } else if (_challengeStatuses[title] == 'Done') {
        _challengeStatuses[title] = 'Finished';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Explore',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Psychoeducation Cards
            const Text(
              'Psychoeducation',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildEduCard(context, '🧠', 'What is Anxiety?', 'Understanding the fight or flight response', const Color(0xFFFF8C42), 
                    'Anxiety is your body\'s natural response to stress. It\'s a feeling of fear or apprehension about what\'s to come. The "fight or flight" response is a physiological reaction that occurs in response to a perceived harmful event, attack, or threat to survival.\n\nWhen this response is triggered, your body releases hormones like adrenaline and cortisol, which increase your heart rate and prepare you to either confront the danger or run away. In modern life, this can be triggered by non-life-threatening situations like public speaking or a difficult meeting.\n\nCommon signs include racing thoughts, tightness in the chest, and restlessness. Gentle breathing, grounding exercises, and naming your worries can help you lower the intensity in the moment.'),
                  _buildEduCard(context, '🌧️', 'Depression 101', 'Why do we feel sad without reason?', const Color(0xFF4A90D9),
                    'Depression is more than just feeling sad for a few days. It is a persistent feeling of sadness and loss of interest that can interfere with your daily life. It can affect how you feel, think, and handle daily activities, such as sleeping, eating, or working.\n\nWhile the exact cause isn\'t known, it\'s often a combination of genetic, biological, environmental, and psychological factors. Understanding that it\'s a clinical condition can help in seeking the right support and realizing that you aren\'t alone in this journey.\n\nSmall actions like sunlight, movement, and regular meals can help stabilize mood. If symptoms persist, seeking professional support can be a strong next step.'),
                  _buildEduCard(context, '⚡', 'Stress vs Burnout', 'How to tell the difference', const Color(0xFF9B6FFF),
                    'Stress and burnout are often used interchangeably, but they are different. Stress is characterized by "over-engagement"—having too much on your plate and feeling like you can\'t handle it. Burnout, on the other hand, is characterized by "disengagement"—feeling empty, devoid of motivation, and beyond caring.\n\nIf stress is like drowning in responsibilities, burnout is like being all dried up. Recognizing the signs early can help you implement self-care strategies and prevent long-term exhaustion.\n\nIf you notice cynicism, numbness, or chronic fatigue, it\'s a sign to reduce load, rest, and rebuild routines with small, realistic goals.'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Daily Challenges
            const Text(
              'Daily Challenges',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildChallengeCard('💧', 'Hydration Goal', 'Drink 3 glasses of water before noon.', AppTheme.green),
            _buildChallengeCard('📝', 'Gratitude Journal', 'Write 2 things you are grateful for today.', AppTheme.accentPurple),
            const SizedBox(height: 32),

          ],
        ),
      ),
    );
  }

  Widget _buildEduCard(BuildContext context, String emoji, String title, String subtitle, Color color, String content) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleScreen(
              title: title,
              content: content,
              emoji: emoji,
              color: color,
            ),
          ),
        );
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'edu-emoji-$title',
              child: Material(
                color: Colors.transparent,
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(String emoji, String title, String subtitle, Color iconColor) {
    String status = _challengeStatuses[title] ?? 'Start';
    String displayTitle = title;
    if (status == 'Done') {
      displayTitle = '$title (In Progress)';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == 'Finished' ? AppTheme.green.withOpacity(0.3) : AppTheme.textDimmed.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: TextStyle(
                    color: status == 'Finished' ? AppTheme.green : AppTheme.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: status == 'Finished' ? null : () => _handleChallengeClick(title),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'Done' ? AppTheme.accentPurple : AppTheme.bgCardLight,
              disabledBackgroundColor: AppTheme.bgCard.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == 'Done' ? Colors.white : (status == 'Finished' ? AppTheme.textDimmed : AppTheme.accentPurple),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
