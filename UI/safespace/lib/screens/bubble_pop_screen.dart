import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../main.dart';

class BubblePopScreen extends StatefulWidget {
  const BubblePopScreen({super.key});

  @override
  State<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends State<BubblePopScreen> with TickerProviderStateMixin {
  final List<_Bubble> _bubbles = [];
  final Random _random = Random();
  int _poppedCount = 0;

  @override
  void initState() {
    super.initState();
    _spawnBubbles();
  }

  void _spawnBubbles() {
    for (int i = 0; i < 15; i++) {
      _addBubble();
    }
  }

  void _addBubble() {
    final size = 40.0 + _random.nextDouble() * 60.0;
    final left = _random.nextDouble() * 300;
    final top = _random.nextDouble() * 600;
    final color = [
      AppTheme.primaryPurple,
      AppTheme.lightPurple,
      AppTheme.accentPurple,
      AppTheme.orange,
      AppTheme.green
    ][_random.nextInt(5)];

    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bubbles.add(_Bubble(
      id: DateTime.now().microsecondsSinceEpoch.toString() + _random.nextInt(1000).toString(),
      left: left,
      top: top,
      size: size,
      color: color,
      controller: animationController,
      isPopped: false,
    ));
  }

  void _popBubble(int index) {
    if (_bubbles[index].isPopped) return;

    HapticFeedback.lightImpact();
    setState(() {
      _bubbles[index].isPopped = true;
      _poppedCount++;
    });
    
    _bubbles[index].controller.forward();

    // Respawn a new bubble after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _bubbles.removeAt(index);
          _addBubble();
        });
      }
    });
  }

  @override
  void dispose() {
    for (var b in _bubbles) {
      b.controller.dispose();
    }
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
          icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bubble Pop', style: TextStyle(color: AppTheme.textWhite)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Take a deep breath.',
                  style: TextStyle(color: AppTheme.textDimmed, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bubbles Popped: $_poppedCount',
                  style: const TextStyle(color: AppTheme.accentPurple, fontSize: 16),
                ),
              ],
            ),
          ),
          
          // Bubbles
          ...List.generate(_bubbles.length, (index) {
            final b = _bubbles[index];
            return Positioned(
              left: b.left,
              top: b.top,
              child: GestureDetector(
                onTap: () => _popBubble(index),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.5).animate(
                    CurvedAnimation(parent: b.controller, curve: Curves.easeOut),
                  ),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.6, end: 0.0).animate(
                      CurvedAnimation(parent: b.controller, curve: Curves.easeOut),
                    ),
                    child: Container(
                      width: b.size,
                      height: b.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: b.color.withOpacity(0.4),
                        border: Border.all(color: b.color.withOpacity(0.8), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: b.color.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      ),
                      // A little white reflection mark to make it look like a bubble
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: b.size * 0.2, top: b.size * 0.2),
                          width: b.size * 0.15,
                          height: b.size * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Bubble {
  final String id;
  final double left;
  final double top;
  final double size;
  final Color color;
  final AnimationController controller;
  bool isPopped;

  _Bubble({
    required this.id,
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    required this.controller,
    required this.isPopped,
  });
}
