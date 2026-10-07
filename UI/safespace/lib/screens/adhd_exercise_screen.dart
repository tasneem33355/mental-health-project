import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../localization.dart';

class AdhdExerciseScreen extends StatefulWidget {
  const AdhdExerciseScreen({super.key});

  @override
  State<AdhdExerciseScreen> createState() => _AdhdExerciseScreenState();
}

class _AdhdExerciseScreenState extends State<AdhdExerciseScreen> {
  int _timerSeconds = 150;
  bool _timerRunning = false;
  Timer? _timer;

  final List<_Task> _tasks = [
    _Task('💡', 'Practice 1 new skill'.tr, 'Build - Every month'.tr, const Color(0xFF9B6FFF), true, false),
    _Task('📚', 'Read a Book'.tr, '02:30', const Color(0xFF4A90D9), false, true),
    _Task('💳', 'Pay your bills'.tr, 'Every month'.tr, const Color(0xFF4CAF82), false, false),
    _Task('🏠', 'Clean up your Home'.tr, 'Every Week'.tr, const Color(0xFFFFD166), false, false),
    _Task('💬', 'Message Someone you love'.tr, 'Every Day'.tr, const Color(0xFFFF8C42), false, false),
    _Task('🏃', 'Exercise'.tr, 'Every Day'.tr, const Color(0xFF4CAF82), false, false),
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
      return;
    }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('ADHD Exercises'.tr, style: TextStyle(color: AppTheme.textWhite, fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Short, practical exercises to help you focus, reset, and build steady habits.'.tr,
                style: TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: task.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(task.emoji, style: const TextStyle(fontSize: 20))),
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
                      decoration: task.completed ? TextDecoration.lineThrough : null,
                      decorationColor: AppTheme.textGrey,
                    )),
                const SizedBox(height: 2),
                task.hasTimer
                    ? GestureDetector(
                        onTap: _toggleTimer,
                        child: Row(
                          children: [
                            Icon(_timerRunning ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                color: AppTheme.accentPurple, size: 16),
                            const SizedBox(width: 4),
                            Text(_formatTime(_timerSeconds),
                                style: TextStyle(color: AppTheme.accentPurple, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : Text(task.subtitle, style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _tasks[index] = _tasks[index].copyWith(completed: !_tasks[index].completed)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: task.completed ? AppTheme.primaryPurple : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: task.completed ? AppTheme.primaryPurple : AppTheme.textDimmed),
              ),
              child: task.completed ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
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
        border: Border(top: BorderSide(color: AppTheme.textDimmed.withOpacity(0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home'.tr),
              _navItem(Icons.explore_outlined, 'Explore'.tr),
              _navItem(Icons.favorite_outline, 'Wellness'.tr),
              _navItem(Icons.person_outline, 'Profile'.tr),
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
        Text(label, style: TextStyle(color: AppTheme.textDimmed, fontSize: 11)),
      ],
    );
  }
}

class _Task {
  final String emoji, title, subtitle;
  final Color color;
  final bool completed, hasTimer;

  _Task(this.emoji, this.title, this.subtitle, this.color, this.completed, this.hasTimer);

  _Task copyWith({bool? completed}) => _Task(emoji, title, subtitle, color, completed ?? this.completed, hasTimer);
}
