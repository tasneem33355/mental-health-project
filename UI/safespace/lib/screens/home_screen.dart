import 'package:flutter/material.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  final List<_PlanItem> _plan = [
    _PlanItem(
        icon: '🌬️',
        title: 'Morning Breathing',
        subtitle: '5 minutes',
        color: Color(0xFF4A90D9)),
    _PlanItem(
        icon: '📓',
        title: 'Daily Gratitude',
        subtitle: 'Journal prompt',
        color: Color(0xFF9B6FFF)),
    _PlanItem(
        icon: '🧠',
        title: 'ADHD Exercise',
        subtitle: 'Daily',
        color: Color(0xFFFF8C42)),
    _PlanItem(
        icon: '🌙',
        title: 'Evening Reflection',
        subtitle: 'Before sleep',
        color: Color(0xFF4CAF82)),
  ];

  final List<_MoodEntry> _moods = [
    _MoodEntry(emoji: '😰', label: 'Stressed', time: 'Slade, 22:45 PM',
        color: Color(0xFFFF5757), checked: true),
    _MoodEntry(emoji: '😊', label: 'Hopeful', time: 'Slade, 22:00 AM',
        color: Color(0xFF4CAF82), checked: true),
    _MoodEntry(emoji: '😟', label: 'Anxious', time: 'Slade, 22:00 AM',
        color: Color(0xFFFFD166), checked: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildQuoteCard(),
              const SizedBox(height: 20),
              _buildActionButtons(context),
              const SizedBox(height: 24),
              _buildPlanSection(),
              const SizedBox(height: 24),
              _buildMoodTimeline(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Good Morning,',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
            Text('Ahmed',
                style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.bgCardLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none,
                  color: AppTheme.textWhite, size: 22),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppTheme.primaryPurple, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D1A8A), Color(0xFF5B2EC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('📖', style: TextStyle(fontSize: 24)),
          SizedBox(height: 12),
          Text(
            '"You don\'t have to control your thoughts. You just have to stop letting them control you."',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '— Dan Millman',
            style: TextStyle(
              color: AppTheme.lightPurple,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttons = [
      _ActionBtn(icon: Icons.check_circle_outline, label: 'Check-In',
          onTap: () => Navigator.pushNamed(context, '/mood-questionnaire')),
      _ActionBtn(icon: Icons.sentiment_satisfied_alt, label: 'Log Mood',
          onTap: () => Navigator.pushNamed(context, '/mood-patterns')),
      _ActionBtn(icon: Icons.history, label: 'History', onTap: () {}),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons.map((b) {
        return Expanded(
          child: GestureDetector(
            onTap: b.onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.textDimmed.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(b.icon, color: AppTheme.accentPurple, size: 26),
                  const SizedBox(height: 8),
                  Text(b.label,
                      style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your Plan',
                style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () {},
              child: const Text('See all',
                  style: TextStyle(color: AppTheme.accentPurple, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._plan.map((item) => _buildPlanItem(item)),
      ],
    );
  }

  Widget _buildPlanItem(_PlanItem item) {
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
              color: item.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item.icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w500,
                        fontSize: 15)),
                Text(item.subtitle,
                    style: const TextStyle(
                        color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppTheme.textDimmed, size: 20),
        ],
      ),
    );
  }

  Widget _buildMoodTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mood Timeline',
            style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        ..._moods.map((m) => _buildMoodEntry(m)),
      ],
    );
  }

  Widget _buildMoodEntry(_MoodEntry mood) {
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
              color: mood.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(mood.emoji,
                    style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mood.label,
                    style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w500,
                        fontSize: 15)),
                Text(mood.time,
                    style: const TextStyle(
                        color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: mood.checked
                  ? AppTheme.primaryPurple
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: mood.checked
                    ? AppTheme.primaryPurple
                    : AppTheme.textDimmed,
              ),
            ),
            child: mood.checked
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_outlined, label: 'Home'),
      _NavItem(icon: Icons.explore_outlined, label: 'Explore'),
      _NavItem(icon: Icons.favorite_outline, label: 'Wellness'),
      _NavItem(icon: Icons.person_outline, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
            top: BorderSide(color: AppTheme.textDimmed.withOpacity(0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = _navIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon,
                        color: selected
                            ? AppTheme.accentPurple
                            : AppTheme.textDimmed,
                        size: 24),
                    const SizedBox(height: 4),
                    Text(item.label,
                        style: TextStyle(
                            color: selected
                                ? AppTheme.accentPurple
                                : AppTheme.textDimmed,
                            fontSize: 11)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PlanItem {
  final String icon, title, subtitle;
  final Color color;
  const _PlanItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color});
}

class _MoodEntry {
  final String emoji, label, time;
  final Color color;
  final bool checked;
  const _MoodEntry(
      {required this.emoji,
      required this.label,
      required this.time,
      required this.color,
      required this.checked});
}

class _ActionBtn {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
