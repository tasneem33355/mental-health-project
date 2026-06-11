import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'signup_screen.dart';
import 'signin_screen.dart';
import 'home_screen.dart';
import 'mood_patterns_screen.dart';
import 'mood_questionnaire_screen.dart';
import 'adhd_exercise_screen.dart';
import 'dass_screen.dart';
import 'dass_results_screen.dart';
import 'profile_screen.dart';
import 'recommendation_screen.dart';
import 'journal_screen.dart';
import 'explore_screen.dart';
import 'wellness_screen.dart';
import 'bubble_pop_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen size for the mockups
    const double screenWidth = 375.0;
    const double screenHeight = 812.0;
    const double scaleFactor = 0.4;

    final screens = [
      _GalleryItem(title: 'Onboarding', widget: const OnboardingScreen()),
      _GalleryItem(title: 'Sign In', widget: const SigninScreen()),
      _GalleryItem(title: 'Sign Up', widget: const SignupScreen()),
      _GalleryItem(title: 'Home', widget: const HomeScreen()),
      _GalleryItem(title: 'Wellness', widget: const WellnessScreen()),
      _GalleryItem(title: 'Explore', widget: const ExploreScreen()),
      _GalleryItem(title: 'Mood Patterns', widget: const MoodPatternsScreen()),
      _GalleryItem(title: 'Mood Questionnaire', widget: const MoodQuestionnaireScreen()),
      _GalleryItem(title: 'ADHD Exercise', widget: const AdhdExerciseScreen()),
      _GalleryItem(title: 'DASS Questionnaire', widget: const DassQuestionnaireScreen()),
      _GalleryItem(
        title: 'DASS Results', 
        widget: const DassResultsScreen(scores: {'Depression': 12, 'Anxiety': 8, 'Stress': 15})
      ),
      _GalleryItem(title: 'Profile', widget: const ProfileScreen()),
      _GalleryItem(title: 'Morning Ritual', widget: const RecommendationScreen(timeOfDay: 'Morning')),
      _GalleryItem(title: 'Journal', widget: const JournalScreen()),
      _GalleryItem(title: 'Bubble Pop', widget: const BubblePopScreen()),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Figma-like background
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Design Gallery (Figma Mode)', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white70),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pinch to zoom, drag to pan. Tap a screen to focus.')),
              );
            },
          ),
        ],
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(1000),
        minScale: 0.1,
        maxScale: 2.0,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(100.0),
            child: Wrap(
              spacing: 40,
              runSpacing: 60,
              children: screens.map((item) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Option to navigate to the actual screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => item.widget),
                        );
                      },
                      child: Container(
                        width: screenWidth * scaleFactor,
                        height: screenHeight * scaleFactor,
                        decoration: BoxDecoration(
                          color: Colors.black, // Bezel color
                          borderRadius: BorderRadius.circular(40 * scaleFactor),
                          border: Border.all(color: const Color(0xFF444444), width: 3), // Outer rim
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // The actual screen content
                            Padding(
                              padding: const EdgeInsets.all(8.0 * scaleFactor), // Inner bezel thickness
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32 * scaleFactor),
                                child: Transform.scale(
                                  scale: scaleFactor,
                                  alignment: Alignment.topLeft,
                                  child: SizedBox(
                                    width: screenWidth - 16, // Adjust for padding
                                    height: screenHeight - 16,
                                    child: IgnorePointer(
                                      child: item.widget,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Simulated Phone Notch
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 150 * scaleFactor,
                                height: 35 * scaleFactor,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20 * scaleFactor),
                                    bottomRight: Radius.circular(20 * scaleFactor),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryItem {
  final String title;
  final Widget widget;

  _GalleryItem({required this.title, required this.widget});
}
