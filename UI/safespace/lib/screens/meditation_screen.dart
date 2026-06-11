import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> with SingleTickerProviderStateMixin {
  int _selectedMinutes = 5;
  bool _isMeditating = false;
  int _secondsRemaining = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startMeditation() {
    setState(() {
      _isMeditating = true;
      _secondsRemaining = _selectedMinutes * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _endMeditation();
      }
    });
  }

  void _endMeditation() {
    _timer?.cancel();
    setState(() => _isMeditating = false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Meditation Complete', style: TextStyle(color: AppTheme.textWhite)),
        content: const Text('You have completed your session. You should feel more calm and centered now.', 
          style: TextStyle(color: AppTheme.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Finish', style: TextStyle(color: AppTheme.accentPurple)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Meditation', style: TextStyle(color: AppTheme.textWhite)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isMeditating) ...[
                const Text(
                  'Set Your Duration',
                  style: TextStyle(color: AppTheme.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'How many minutes would you like to meditate today?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeButton(1),
                    const SizedBox(width: 12),
                    _buildTimeButton(5),
                    const SizedBox(width: 12),
                    _buildTimeButton(10),
                    const SizedBox(width: 12),
                    _buildTimeButton(20),
                  ],
                ),
                const SizedBox(height: 64),
                ElevatedButton(
                  onPressed: _startMeditation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Start Meditation'),
                ),
              ] else ...[
                FadeTransition(
                  opacity: Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.05).animate(_pulseController),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentPurple.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                Text(
                  _formatTime(_secondsRemaining),
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Breathe deeply and let go...',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 18, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 80),
                TextButton(
                  onPressed: () {
                    _timer?.cancel();
                    setState(() => _isMeditating = false);
                  },
                  child: const Text('Cancel Session', style: TextStyle(color: AppTheme.red)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(int mins) {
    bool selected = _selectedMinutes == mins;
    return GestureDetector(
      onTap: () => setState(() => _selectedMinutes = mins),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryPurple : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primaryPurple : AppTheme.textDimmed.withOpacity(0.3),
          ),
        ),
        child: Text(
          '$mins m',
          style: TextStyle(
            color: selected ? AppTheme.textWhite : AppTheme.textGrey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
