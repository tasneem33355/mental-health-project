import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
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
  await Loc.init();
  runApp(const SafespaceApp());
}

class SafespaceApp extends StatefulWidget {
  const SafespaceApp({super.key});

  @override
  State<SafespaceApp> createState() => _SafespaceAppState();
}

class _SafespaceAppState extends State<SafespaceApp> {
  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isLight = prefs.getBool('is_light_mode') ?? false;
    AppTheme.themeNotifier.value = isLight ? ThemeMode.light : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: Loc.localeNotifier,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: AppTheme.themeNotifier,
          builder: (context, currentMode, _) {
            return MaterialApp(
              title: 'Safespace'.tr,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentMode,
              locale: locale,
              builder: (context, child) {
                return Directionality(
                  textDirection: Loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: child!,
                );
              },
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
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
          },
        );
      },
    );
  }
}

class AppTheme {
  // Theme notifier
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  static bool get isDark => themeNotifier.value == ThemeMode.dark;

  // Toggle theme and save choice to local storage
  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (isDark) {
      themeNotifier.value = ThemeMode.light;
      await prefs.setBool('is_light_mode', true);
    } else {
      themeNotifier.value = ThemeMode.dark;
      await prefs.setBool('is_light_mode', false);
    }
  }

  // Colors dynamically mapping between Dark/Light modes based on brand identity guidelines
  static Color get bgDark => isDark ? const Color(0xFF0D0720) : const Color(0xFFFAFAFA); // Soft Neutral (#FAFAFA)
  static Color get bgCard => isDark ? const Color(0xFF1A1035) : const Color(0xFFFFFFFF); // White background cards
  static Color get bgCardLight => isDark ? const Color(0xFF221545) : const Color(0xFFEEF3FC); // Soft tinted blue-grey card

  static Color get primaryPurple => isDark ? const Color(0xFF7B3FE4) : const Color(0xFF7B3FE4); // Keeps core branding identity signature
  static Color get accentPurple => isDark ? const Color(0xFF9B6FFF) : const Color(0xFF6CBCF5); // Calm Indigo (#6CBCF5)
  static Color get lightPurple => isDark ? const Color(0xFFB99EFF) : const Color(0xFF4A60A0); // Deep Indigo (#4A60A0)

  static Color get textWhite => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF4A60A0); // Deep Indigo text
  static Color get textGrey => isDark ? const Color(0xFFAA9EC8) : const Color(0xFF6778A5); // Soft Indigo body text
  static Color get textDimmed => isDark ? const Color(0xFF6B5E8A) : const Color(0xFF909CBA); // Muted grey-blue text

  static Color get green => isDark ? const Color(0xFF4CAF82) : const Color(0xFFA8E6CF); // Gentle Mint (#A8E6CF)
  static Color get orange => isDark ? const Color(0xFFFF8C42) : const Color(0xFFFFAAA5); // Soft Coral (#FFAAA5)
  static Color get red => isDark ? const Color(0xFFFF5757) : const Color(0xFFFF7E7E); // Pastel Red
  static Color get yellow => isDark ? const Color(0xFFFFD166) : const Color(0xFFFFD166);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.dark(
          primary: primaryPurple,
          secondary: accentPurple,
          surface: bgCard,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: textWhite),
          bodyMedium: TextStyle(color: textGrey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgCardLight,
          hintStyle: TextStyle(color: textDimmed),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: bgDark,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.light(
          primary: primaryPurple,
          secondary: accentPurple,
          surface: bgCard,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: textWhite),
          bodyMedium: TextStyle(color: textGrey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgCardLight,
          hintStyle: TextStyle(color: textDimmed),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
