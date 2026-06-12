import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mood_patterns_screen.dart';
import 'screens/mood_questionnaire_screen.dart';
import 'screens/adhd_exercise_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/bubble_pop_screen.dart';
import 'screens/color_match_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/assessment_intro_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await Supabase.initialize(
    url: 'https://cwjbutxytglfxzdrvwok.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3amJ1dHh5dGdsZnh6ZHJ2d29rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwOTE4NzUsImV4cCI6MjA5NjY2Nzg3NX0.G-M4KPFTYX0d5QaV3NmsSwd4Ru50jjyLgGviNd9VOGo',
  );

  await AppState.init();
  runApp(const SafespaceApp());
}

class SafespaceApp extends StatelessWidget {
  const SafespaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safespace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashScreen(),
        '/onboarding': (ctx) => const OnboardingScreen(),
        '/signup': (ctx) => const SignupScreen(),
        '/signin': (ctx) => const SigninScreen(),
        '/home': (ctx) => const HomeScreen(),
        '/mood-patterns': (ctx) => const MoodPatternsScreen(),
        '/mood-questionnaire': (ctx) => const MoodQuestionnaireScreen(),
        '/adhd-exercise': (ctx) => const AdhdExerciseScreen(),
        '/assessment': (ctx) => const AssessmentIntroScreen(),
        '/assessment-start': (ctx) => const AssessmentScreen(),
        '/profile': (ctx) => const ProfileScreen(),
        '/morning-ritual': (ctx) =>
            const RecommendationScreen(timeOfDay: 'Morning'),
        '/nightly-unwind': (ctx) =>
            const RecommendationScreen(timeOfDay: 'Evening'),
        '/journal': (ctx) => const JournalScreen(),
        '/bubble-pop': (ctx) => const BubblePopScreen(),
        '/color-match': (ctx) => const ColorMatchScreen(),
        '/settings': (ctx) => const SettingsScreen(),
      },
    );
  }
}

class AppTheme {
  // Colors
  static const Color bgDark = Color(0xFF0D0720);
  static const Color bgCard = Color(0xFF1A1035);
  static const Color bgCardLight = Color(0xFF221545);
  static const Color primaryPurple = Color(0xFF7B3FE4);
  static const Color accentPurple = Color(0xFF9B6FFF);
  static const Color lightPurple = Color(0xFFB99EFF);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFAA9EC8);
  static const Color textDimmed = Color(0xFF6B5E8A);
  static const Color green = Color(0xFF4CAF82);
  static const Color orange = Color(0xFFFF8C42);
  static const Color red = Color(0xFFFF5757);
  static const Color yellow = Color(0xFFFFD166);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        fontFamily: 'SF Pro Display',
        colorScheme: const ColorScheme.dark(
          primary: primaryPurple,
          secondary: accentPurple,
          surface: bgCard,
        ),
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(color: textWhite, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: textWhite),
          bodyMedium: TextStyle(color: textGrey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgCardLight,
          hintStyle: const TextStyle(color: textDimmed),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
