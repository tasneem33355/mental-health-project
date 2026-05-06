import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'grounding_screen.dart';
import 'box_breathing_screen.dart';
import 'meditation_screen.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ApiService.getHistory();
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
              'Wellness',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),


            
            // Wellness Tools
            const Text(
              'Wellness Tools',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildToolCard('🌬️', 'Box Breathing', AppTheme.primaryPurple, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BoxBreathingScreen()),
                  );
                })),
                const SizedBox(width: 16),
                Expanded(child: _buildToolCard('⚓', '5-4-3-2-1 Grounding', AppTheme.green, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GroundingScreen()),
                  );
                })),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildToolCard('🧘', 'Meditation', AppTheme.accentPurple, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MeditationScreen()),
                  );
                })),
                const SizedBox(width: 16),
                const Spacer(), // Empty space for the 4th card if added later
              ],
            ),
            const SizedBox(height: 32),

            // Mini Games (Moved from Explore)
            const Text(
              'Mini Games',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMiniGameCard(context, '🎈', 'Bubble Pop', 'Fidget & Relax', '/bubble-pop')),
                const SizedBox(width: 16),
                Expanded(child: _buildMiniGameCard(context, '🎨', 'Color Match', 'Distract your mind', '/color-match')),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }







  Widget _buildMiniGameCard(BuildContext context, String emoji, String title, String subtitle, String? route) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.textDimmed.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(String emoji, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
