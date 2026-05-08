import 'package:flutter/material.dart';
import '../main.dart';

class MoodPatternsScreen extends StatelessWidget {
  const MoodPatternsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppTheme.textWhite, size: 16),
          ),
        ),
        title: const Text('Mood Patterns',
            style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.notifications_none,
                  color: AppTheme.textWhite, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Here's a look at your mood patterns for this week.",
              style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Stress insight chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.access_time, color: AppTheme.textGrey, size: 16),
                  SizedBox(width: 8),
                  Text('Higher stress on Wed, Fri, Sat',
                      style: TextStyle(
                          color: AppTheme.textWhite, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bar Chart
            _MoodBarChart(),
            const SizedBox(height: 24),

            // Mood Timeline
            const Text('Mood Timeline',
                style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),

            _moodTimelineEntry('😰', 'Stressed', 'Slade, 22:45 PM',
                const Color(0xFFFF5757), true),
            _moodTimelineEntry('😊', 'Hopeful', 'Slade, 22:00 AM',
                AppTheme.green, true),
            _moodTimelineEntry('😟', 'Anxious', 'Slade, 22:00 AM',
                AppTheme.yellow, false),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _moodTimelineEntry(
      String emoji, String label, String time, Color color, bool checked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w500,
                        fontSize: 15)),
                Text(time,
                    style: const TextStyle(
                        color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: checked ? AppTheme.primaryPurple : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                  color: checked ? AppTheme.primaryPurple : AppTheme.textDimmed),
            ),
            child: checked
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border:
            Border(top: BorderSide(color: AppTheme.textDimmed.withOpacity(0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', false),
              _navItem(Icons.explore_outlined, 'Explore', false),
              _navItem(Icons.favorite_outline, 'Wellness', false),
              _navItem(Icons.person_outline, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool selected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            color:
                selected ? AppTheme.accentPurple : AppTheme.textDimmed,
            size: 24),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color:
                    selected ? AppTheme.accentPurple : AppTheme.textDimmed,
                fontSize: 11)),
      ],
    );
  }
}

class _MoodBarChart extends StatelessWidget {
  const _MoodBarChart();

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Fri', 'Sat', 'Sun'];
    final values = [0.4, 0.5, 0.85, 0.3, 0.75, 0.6];
    final highlighted = [false, false, true, false, true, false];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Y-axis labels
          const Row(
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('11M', style: TextStyle(color: AppTheme.textDimmed, fontSize: 10)),
                    SizedBox(height: 28),
                    Text('9M', style: TextStyle(color: AppTheme.textDimmed, fontSize: 10)),
                    SizedBox(height: 28),
                    Text('6M', style: TextStyle(color: AppTheme.textDimmed, fontSize: 10)),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(child: SizedBox(height: 80)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(width: 32),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(days.length, (i) {
                    return _Bar(
                      label: days[i],
                      value: values[i],
                      highlighted: highlighted[i],
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  final bool highlighted;

  const _Bar(
      {required this.label, required this.value, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 28,
          height: 80 * value,
          decoration: BoxDecoration(
            color: highlighted ? AppTheme.primaryPurple : AppTheme.bgCardLight,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: highlighted ? AppTheme.accentPurple : AppTheme.textDimmed,
                fontSize: 11)),
      ],
    );
  }
}
