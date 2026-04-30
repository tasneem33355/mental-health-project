import 'package:flutter/material.dart';
import '../main.dart';

class MoodQuestionnaireScreen extends StatefulWidget {
  const MoodQuestionnaireScreen({super.key});

  @override
  State<MoodQuestionnaireScreen> createState() =>
      _MoodQuestionnaireScreenState();
}

class _MoodQuestionnaireScreenState extends State<MoodQuestionnaireScreen> {
  int _step = 0;
  int? _stressLevel; // 0=Calm .. 4=Very stressed
  double _energyLevel = 0.7;
  int? _sleepQuality; // 0=Poor..4=Amazing

  final List<String> _stressEmojis = ['😌', '🙂', '😐', '😤', '😰'];
  final List<String> _stressLabels = ['Calm', '', '', '', 'Very stressed'];
  final List<String> _sleepOptions = ['Poor', 'Okay', 'Good', 'Great', 'Amazing'];

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
                  onPressed: () => Navigator.pop(context),
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
        ? (_stressLevel! < 2 ? 'You feel calm 😌' : 'You feel a little tense, but man...')
        : null;
    final badge = _stressLevel != null && _stressLevel! >= 3
        ? 'Moderate'
        : null;

    return _QuestionCard(
      question: 'Question 1 of 3',
      text: 'How stressed do you feel right now?',
      result: result,
      badge: badge,
      badgeColor: AppTheme.orange,
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
                    ? AppTheme.primaryPurple.withOpacity(0.3)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: AppTheme.primaryPurple)
                    : null,
              ),
              child: Text(_stressEmojis[i],
                  style: TextStyle(fontSize: selected ? 28 : 22)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEnergyCard() {
    String result;
    Color resultColor;
    if (_energyLevel < 0.3) {
      result = 'Your energy feels very low';
      resultColor = AppTheme.red;
    } else if (_energyLevel < 0.6) {
      result = 'Your energy feels moderate';
      resultColor = AppTheme.orange;
    } else {
      result = 'Your energy feels steady and posi...';
      resultColor = AppTheme.green;
    }
    final badge = _energyLevel >= 0.6 ? 'High' : (_energyLevel >= 0.3 ? 'Mid' : 'Low');
    final badgeColor = _energyLevel >= 0.6
        ? AppTheme.green
        : (_energyLevel >= 0.3 ? AppTheme.orange : AppTheme.red);

    return _QuestionCard(
      question: 'Question 2 of 3',
      text: 'How is your energy level today?',
      result: result,
      resultColor: resultColor,
      badge: badge,
      badgeColor: badgeColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Very low',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 11)),
              Text('Very high',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryPurple,
              inactiveTrackColor: AppTheme.bgCardLight,
              thumbColor: Colors.white,
              overlayColor: AppTheme.primaryPurple.withOpacity(0.2),
              trackHeight: 6,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _energyLevel,
              onChanged: (v) => setState(() => _energyLevel = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard() {
    final result = _sleepQuality != null
        ? (_sleepQuality! >= 2
            ? 'You got enough rest and wok...'
            : 'You could use more rest...')
        : null;
    final badge = _sleepQuality != null && _sleepQuality! >= 2 ? 'Good sleep' : null;

    return _QuestionCard(
      question: 'Question 3 of 3',
      text: 'How well did you sleep last night?',
      result: result,
      badge: badge,
      badgeColor: AppTheme.green,
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
                    ? _sleepColors[i].withOpacity(0.25)
                    : AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(20),
                border: selected
                    ? Border.all(color: _sleepColors[i])
                    : null,
              ),
              child: Text(
                _sleepOptions[i],
                style: TextStyle(
                  color: selected ? _sleepColors[i] : AppTheme.textGrey,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final String text;
  final Widget child;
  final String? result;
  final Color? resultColor;
  final String? badge;
  final Color? badgeColor;

  const _QuestionCard({
    required this.question,
    required this.text,
    required this.child,
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
              const Icon(Icons.emoji_emotions_outlined,
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
