import 'package:flutter/material.dart';
import '../main.dart';

class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _currentAction = 'Inhale';
  int _secondsRemaining = 4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16), // 4 seconds per side
    );

    _animation = Tween<double>(begin: 0, end: 4).animate(_controller)
      ..addListener(() {
        setState(() {
          double val = _animation.value;
          if (val < 1) {
            _currentAction = 'Inhale';
            _secondsRemaining = 4 - (val * 4).floor();
          } else if (val < 2) {
            _currentAction = 'Hold';
            _secondsRemaining = 4 - ((val - 1) * 4).floor();
          } else if (val < 3) {
            _currentAction = 'Exhale';
            _secondsRemaining = 4 - ((val - 2) * 4).floor();
          } else {
            _currentAction = 'Hold';
            _secondsRemaining = 4 - ((val - 3) * 4).floor();
          }
        });
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Box Breathing',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Follow the dot and synchronize your breath.',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
            ),
            const Spacer(),
            
            // The Breathing Box
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The Square Track
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3), width: 4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  
                  // The Animated Dot (Impulse)
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      double val = _animation.value;
                      double top = 0;
                      double left = 0;

                      if (val < 1) {
                        // Moving Down (Inhale)
                        top = val * 200;
                        left = 0;
                      } else if (val < 2) {
                        // Moving Right (Hold)
                        top = 200;
                        left = (val - 1) * 200;
                      } else if (val < 3) {
                        // Moving Up (Exhale)
                        top = 200 - ((val - 2) * 200);
                        left = 200;
                      } else {
                        // Moving Left (Hold)
                        top = 0;
                        left = 200 - ((val - 3) * 200);
                      }

                      return Positioned(
                        top: top - 10,
                        left: left - 10,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentPurple,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: AppTheme.accentPurple, blurRadius: 10, spreadRadius: 2),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Central Text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentAction,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_secondsRemaining',
                        style: const TextStyle(
                          color: AppTheme.accentPurple,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Explanation Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is Box Breathing?',
                    style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Also known as four-square breathing, it is a simple technique used to reduce stress and improve focus. It involves breathing in, holding, breathing out, and holding again, each for an equal count of 4 seconds.',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
