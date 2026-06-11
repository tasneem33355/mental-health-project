import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_state.dart';

class MoodQuestionnaireScreen extends StatefulWidget {
  const MoodQuestionnaireScreen({super.key});

  @override
  State<MoodQuestionnaireScreen> createState() =>
      _MoodQuestionnaireScreenState();
}

class _MoodQuestionnaireScreenState extends State<MoodQuestionnaireScreen> {
  final int _step = 0;
  int? _stressLevel; // 0=Calm .. 4=Very stressed
  double? _energyLevel;
  int? _sleepQuality; // 0=Poor..4=Amazing

  final List<String> _stressEmojis = ['😰', '😣', '😐', '🙂', '😌'];
  final List<String> _stressLabels = ['Very stressed', 'Tense', 'Neutral', 'Light', 'Calm'];
  final List<String> _sleepOptions = ['<4h', '4-5h', '5-6h', '6-7h', '8h+'];

  final List<Color> _sleepColors = [
    AppTheme.red,
    AppTheme.orange,
    AppTheme.green,
    AppTheme.green,
    const Color(0xFF2ECC71),
  ];

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
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.4)),
          ),
          child: const Text('Daily check-in',
              style: TextStyle(
                  color: AppTheme.accentPurple,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mood Questionnaire',
                style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Answer all three questions in one place with a calm, quick survey flow.',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),

              // Step cards
              _buildStressCard(),
              const SizedBox(height: 16),
              _buildEnergyCard(),
              const SizedBox(height: 16),
              _buildSleepCard(),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_stressLevel == null || _energyLevel == null || _sleepQuality == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please answer all questions')),
                      );
                      return;
                    }
                    AppState.addMoodRecord(
                      4 - _stressLevel!, // Invert back so 0=Calm, 4=Very Stressed for backend
                      _energyLevel!,
                      _sleepQuality!,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Daily check-in completed!')),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStressCard() {
    final result = _stressLevel != null
        ? (_stressLevel! > 2 ? 'You feel calm 😌' : 'You feel a little tense today.')
        : null;
    final badge = _stressLevel != null && _stressLevel! <= 1
        ? 'High'
        : null;

    return _QuestionCard(
      question: 'Question 1 of 3',
      text: 'How stressed do you feel right now?',
      icon: Icons.favorite_border,
      result: result,
      badge: badge,
      badgeColor: AppTheme.orange,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.4), Colors.red.withOpacity(0.4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_stressEmojis.length, (i) {
            final selected = _stressLevel == i;
            return GestureDetector(
              onTap: () => setState(() => _stressLevel = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primaryPurple.withOpacity(0.5)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: selected
                      ? Border.all(color: AppTheme.primaryPurple)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(_stressEmojis[i],
                        style: TextStyle(fontSize: selected ? 28 : 22)),
                    const SizedBox(height: 4),
                    Text(
                      _stressLabels[i],
                      style: TextStyle(
                        color: selected ? AppTheme.textWhite : AppTheme.textWhite.withOpacity(0.6),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEnergyCard() {
    String? result;
    Color? resultColor;
    String? badge;
    Color? badgeColor;
    
    if (_energyLevel != null) {
      if (_energyLevel! < 0.3) {
        result = 'Your energy feels very low';
        resultColor = AppTheme.red;
      } else if (_energyLevel! < 0.6) {
        result = 'Your energy feels moderate';
        resultColor = AppTheme.orange;
      } else {
        result = 'Your energy feels steady and positive.';
        resultColor = AppTheme.green;
      }
      badge = _energyLevel! >= 0.6 ? 'High' : (_energyLevel! >= 0.3 ? 'Mid' : 'Low');
      badgeColor = _energyLevel! >= 0.6
          ? AppTheme.green
          : (_energyLevel! >= 0.3 ? AppTheme.orange : AppTheme.red);
    }

    return _QuestionCard(
      question: 'Question 2 of 3',
      text: 'How is your energy level today?',
      icon: Icons.bolt_outlined,
      result: result,
      resultColor: resultColor,
      badge: badge,
      badgeColor: badgeColor,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.grey.withOpacity(0.4), Colors.teal.withOpacity(0.4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _energyChoice('Low', 0.2, AppTheme.red),
            _energyChoice('Medium', 0.5, AppTheme.orange),
            _energyChoice('High', 0.8, AppTheme.green),
          ],
        ),
      ),
    );
  }

  Widget _energyChoice(String label, double value, Color color) {
    final selected = _energyLevel != null && (_energyLevel! - value).abs() < 0.01;
    return GestureDetector(
      onTap: () => setState(() => _energyLevel = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppTheme.bgCardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : AppTheme.textDimmed.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppTheme.textGrey,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSleepCard() {
    final result = _sleepQuality != null
        ? (_sleepQuality! >= 2
            ? 'You got enough rest and woke up okay.'
            : 'You could use more rest tonight.')
        : null;
    final badge = _sleepQuality != null && _sleepQuality! >= 2 ? 'Good sleep' : null;

    return _QuestionCard(
      question: 'Question 3 of 3',
      text: 'How well did you sleep last night?',
      icon: Icons.nightlight_outlined,
      result: result,
      badge: badge,
      badgeColor: AppTheme.green,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.5), Colors.purple.withOpacity(0.5)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_sleepOptions.length, (i) {
            final selected = _sleepQuality == i;
            return GestureDetector(
              onTap: () => setState(() => _sleepQuality = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.bgCardLight
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: selected
                      ? Border.all(color: AppTheme.textWhite)
                      : null,
                ),
                child: Text(
                  _sleepOptions[i],
                  style: TextStyle(
                    color: selected ? AppTheme.textWhite : AppTheme.textWhite.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final String text;
  final Widget child;
  final IconData icon;
  final String? result;
  final Color? resultColor;
  final String? badge;
  final Color? badgeColor;

  const _QuestionCard({
    required this.question,
    required this.text,
    required this.child,
    required this.icon,
    this.result,
    this.resultColor,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(question,
                  style: const TextStyle(
                      color: AppTheme.accentPurple, fontSize: 12)),
              Icon(icon,
                  color: AppTheme.textDimmed, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(text,
              style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 14),
          child,
          if (result != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    result!,
                    style: TextStyle(
                        color: resultColor ?? AppTheme.textGrey,
                        fontSize: 13),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? AppTheme.green).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: (badgeColor ?? AppTheme.green).withOpacity(0.5)),
                    ),
                    child: Text(badge!,
                        style: TextStyle(
                            color: badgeColor ?? AppTheme.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
