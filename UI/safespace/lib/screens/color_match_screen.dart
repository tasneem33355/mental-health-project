import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../main.dart';

class ColorMatchScreen extends StatefulWidget {
  const ColorMatchScreen({super.key});

  @override
  State<ColorMatchScreen> createState() => _ColorMatchScreenState();
}

class _ColorMatchScreenState extends State<ColorMatchScreen> {
  final Random _random = Random();
  late String _currentWord;
  late Color _currentFontColor;
  int _score = 0;
  int _timeLeft = 30;
  bool _isPlaying = false;
  Timer? _timer;

  final List<Map<String, dynamic>> _colorData = [
    {'name': 'RED', 'color': AppTheme.red},
    {'name': 'GREEN', 'color': AppTheme.green},
    {'name': 'BLUE', 'color': Colors.blue},
    {'name': 'YELLOW', 'color': AppTheme.yellow},
    {'name': 'ORANGE', 'color': AppTheme.orange},
    {'name': 'PURPLE', 'color': AppTheme.primaryPurple},
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isPlaying = true;
    });
    _nextRound();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _nextRound() {
    int wordIdx = _random.nextInt(_colorData.length);
    int colorIdx = _random.nextInt(_colorData.length);
    setState(() {
      _currentWord = _colorData[wordIdx]['name'];
      _currentFontColor = _colorData[colorIdx]['color'];
    });
  }

  void _checkAnswer(Color tappedColor) {
    if (!_isPlaying) return;
    
    if (tappedColor == _currentFontColor) {
      setState(() => _score += 10);
      _nextRound();
    } else {
      setState(() => _score = max(0, _score - 5));
      // Subtle shake or feedback could go here
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _isPlaying = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Game Over!', style: TextStyle(color: AppTheme.textWhite)),
        content: Text('Your score: $_score', style: const TextStyle(color: AppTheme.textGrey)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Play Again', style: TextStyle(color: AppTheme.accentPurple)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: AppTheme.textGrey)),
          ),
        ],
      ),
    );
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
        title: const Text('Color Match', style: TextStyle(color: AppTheme.textWhite)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Score', '$_score'),
                _buildStatCard('Time', '${_timeLeft}s'),
              ],
            ),
            const Spacer(),
            if (!_isPlaying)
              Column(
                children: [
                  const Icon(Icons.palette_outlined, size: 80, color: AppTheme.accentPurple),
                  const SizedBox(height: 24),
                  const Text(
                    'Focus Challenge',
                    style: TextStyle(color: AppTheme.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap the button that matches the FONT COLOR of the word, not what the word says!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Start Game'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _currentWord,
                      key: ValueKey(_currentWord + _currentFontColor.toString()),
                        style: TextStyle(
                          color: _currentFontColor,
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: _colorData.map((data) {
                      return GestureDetector(
                        onTap: () => _checkAnswer(data['color']),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: data['color'],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: data['color'].withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
