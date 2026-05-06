import 'package:flutter/material.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _pages = [
    const _OnboardingItem(
      title: 'Safespace Helps You Understand How\nYou Feel And Guides Your Toward\nHealthy Recovery',
      emoji: '🧘',
      color: Color(0xFF7B3FE4),
    ),
    const _OnboardingItem(
      title: 'Track Your Mood Daily\nAnd Discover Your Emotional Patterns',
      emoji: '📊',
      color: Color(0xFF5B2EC4),
    ),
    const _OnboardingItem(
      title: 'Build Healthy Habits\nWith Guided Exercises And Mindfulness',
      emoji: '🌟',
      color: Color(0xFF9B4FF4),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A3E), AppTheme.bgDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentPurple.withOpacity(0.4),
                        ),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          color: AppTheme.accentPurple, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Safespace',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (ctx, i) => _buildPage(_pages[i]),
                ),
              ),

              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppTheme.accentPurple
                          : AppTheme.textDimmed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/signin'),
                        child: const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/signup'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accentPurple,
                          side: const BorderSide(color: AppTheme.accentPurple),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Sign Up'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  item.color.withOpacity(0.4),
                  item.color.withOpacity(0.0),
                ],
              ),
            ),
            child: Center(
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 90),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  final String title;
  final String emoji;
  final Color color;
  const _OnboardingItem(
      {required this.title, required this.emoji, required this.color});
}
