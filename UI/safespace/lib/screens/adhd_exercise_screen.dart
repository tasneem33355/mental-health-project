import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart';

class AdhdExerciseScreen extends StatefulWidget {
  const AdhdExerciseScreen({super.key});

  @override
  State<AdhdExerciseScreen> createState() => _AdhdExerciseScreenState();
}

class _AdhdExerciseScreenState extends State<AdhdExerciseScreen> {
  // Timer state for "Read a Book"
  int _timerSeconds = 2 * 60 + 30; // 2:30
  bool _timerRunning = false;
  Timer? _timer;

  final List<_Task> _tasks = [
    const _Task(
        emoji: '💡',
        title: 'Practice 1 new skill',
        subtitle: 'Build - Every month',
        color: Color(0xFF9B6FFF),
        completed: true,
        hasTimer: false),
    const _Task(
        emoji: '📚',
        title: 'Read a Book',
        subtitle: '02:30',
        color: Color(0xFF4A90D9),
        completed: false,
        hasTimer: true),
    const _Task(
        emoji: '💳',
        title: 'Pay your bills',
        subtitle: 'Every month',
        color: Color(0xFF4CAF82),
        completed: false,
        hasTimer: false),
    const _Task(
        emoji: '💳',
        title: 'Pay your bills',
        subtitle: 'Every month',
        color: Color(0xFFFF5757),
        completed: false,
        hasTimer: false),
    const _Task(
        emoji: '🏠',
        title: 'Clean up your Home',
        subtitle: 'Every Week',
        color: Color(0xFFFFD166),
        completed: false,
        hasTimer: false),
    const _Task(
        emoji: '💬',
        title: 'Message Someone you love',
        subtitle: 'Every Day',
        color: Color(0xFFFF8C42),
        completed: false,
        hasTimer: false),
    const _Task(
        emoji: '🏃',
        title: 'Exercise',
        subtitle: 'Every Day',
        color: Color(0xFF4CAF82),
        completed: false,
        hasTimer: false),
    const _Task(
        emoji: '🏃',
        title: 'Exercise',
        subtitle: 'Every Day',
        color: Color(0xFF4A90D9),
        completed: false,
        hasTimer: false),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_timerRunning) {
      _timer?.cancel();
      setState(() => _timerRunning = false);
    } else {
      setState(() => _timerRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_timerSeconds > 0) {
          setState(() => _timerSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _timerRunning = false);
        }
      });
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

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
        title: const Text('ADHD Exercises',
            style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Short, practical exercises to help you focus, reset, and build steady habits.',
              style: TextStyle(
                  color: AppTheme.textGrey, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _tasks.length,
              itemBuilder: (ctx, i) => _buildTaskItem(_tasks[i], i),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTaskItem(_Task task, int index) {
    final isTimerTask = task.hasTimer;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              color: task.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(task.emoji,
                    style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: AppTheme.textGrey,
                    )),
                const SizedBox(height: 2),
                isTimerTask
                    ? GestureDetector(
                        onTap: _toggleTimer,
                        child: Row(
                          children: [
                            Icon(
                              _timerRunning
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              color: AppTheme.accentPurple,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(_timerSeconds),
                              style: const TextStyle(
                                  color: AppTheme.accentPurple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : Text(task.subtitle,
                        style: const TextStyle(
                            color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),
          // Toggle checkbox
          GestureDetector(
            onTap: () => setState(() => _tasks[index] =
                _Task.from(task, completed: !task.completed)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: task.completed
                    ? AppTheme.primaryPurple
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.completed
                      ? AppTheme.primaryPurple
                      : AppTheme.textDimmed,
                ),
              ),
              child: task.completed
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
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
              _navItem(Icons.home_outlined, 'Home'),
              _navItem(Icons.explore_outlined, 'Explore'),
              _navItem(Icons.favorite_outline, 'Wellness'),
              _navItem(Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textDimmed, size: 24),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: AppTheme.textDimmed, fontSize: 11)),
      ],
    );
  }
}

class _Task {
  final String emoji, title, subtitle;
  final Color color;
  final bool completed, hasTimer;

  const _Task({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.completed,
    required this.hasTimer,
  });

  factory _Task.from(_Task t, {bool? completed}) => _Task(
        emoji: t.emoji,
        title: t.title,
        subtitle: t.subtitle,
        color: t.color,
        completed: completed ?? t.completed,
        hasTimer: t.hasTimer,
      );
}
