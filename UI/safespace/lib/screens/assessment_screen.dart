import 'package:flutter/material.dart';
import '../main.dart';
import '../data/dass_questions.dart';
import '../data/app_state.dart';
import '../services/api_service.dart';
import 'dass_results_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _textController = TextEditingController();
  int _currentIndex = 0;
  final Map<int, int> _answers = {};

  final List<String> _options = [
    'Did not apply to me at all',
    'Applied to me to some degree',
    'Applied to me to a considerable degree',
    'Applied to me very much',
  ];

  void _onOptionSelected(int value) {
    setState(() {
      _answers[_currentIndex] = value;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentIndex < dassQuestions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write how you feel before submitting.')),
      );
      return;
    }

    if (_answers.length < dassQuestions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all questions (${_answers.length}/${dassQuestions.length})'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    final depressionIdx = [2, 4, 9, 12, 15, 16, 20, 23, 25, 30, 33, 36, 37, 41];
    final anxietyIdx = [1, 3, 6, 8, 14, 18, 19, 22, 24, 27, 29, 35, 39, 40];
    final stressIdx = [0, 5, 7, 10, 11, 13, 17, 21, 26, 28, 31, 32, 34, 38];

    int depressionScore = 0;
    int anxietyScore = 0;
    int stressScore = 0;

    _answers.forEach((index, value) {
      int score = value;
      if (depressionIdx.contains(index)) depressionScore += score;
      if (anxietyIdx.contains(index)) anxietyScore += score;
      if (stressIdx.contains(index)) stressScore += score;
    });

    AppState.lastDassResults = {
      'Depression': depressionScore,
      'Anxiety': anxietyScore,
      'Stress': stressScore,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryPurple),
      ),
    );

    List<int> surveyAnswers = List.generate(42, (i) => _answers[i] ?? 0);

    ApiService.analyzeMentalHealth(text, surveyAnswers).then((result) {
      Navigator.pop(context);

      AppState.lastDassResults = {
        'Depression': depressionScore,
        'Anxiety': anxietyScore,
        'Stress': stressScore,
      };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DassResultsScreen(
            scores: {
              'Depression': depressionScore,
              'Anxiety': anxietyScore,
              'Stress': stressScore,
            },
            apiResult: result,
          ),
        ),
      );
    }).catchError((e) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DassResultsScreen(
            scores: {
              'Depression': depressionScore,
              'Anxiety': anxietyScore,
              'Stress': stressScore,
            },
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentIndex + 1) / dassQuestions.length;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Full Assessment',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Text + DASS-42',
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentIndex + 1} of ${dassQuestions.length}',
                      style: const TextStyle(
                        color: AppTheme.accentPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.bgCardLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: dassQuestions.length,
              itemBuilder: (context, index) {
                final question = dassQuestions[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextCard(),
                      const SizedBox(height: 24),
                      _buildQuestionCard(question.text, index),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  TextButton.icon(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_back, color: AppTheme.accentPurple),
                    label: const Text('Previous', style: TextStyle(color: AppTheme.accentPurple)),
                  )
                else
                  const SizedBox(),
                if (_currentIndex == dassQuestions.length - 1)
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Finish'),
                  )
                else
                  const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling right now?',
            style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Write in Arabic or English. This text is used with the survey for a combined analysis.',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 6),
          const Text(
            'This assessment is for awareness only and not a medical diagnosis.',
            style: TextStyle(color: AppTheme.textDimmed, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 4,
            style: const TextStyle(color: AppTheme.textWhite),
            decoration: const InputDecoration(
              hintText: 'Type how you feel...'
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String text, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.psychology_outlined, color: AppTheme.accentPurple),
        ),
        const SizedBox(height: 24),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 48),
        ...List.generate(_options.length, (optIdx) {
          bool selected = _answers[index] == optIdx;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _onOptionSelected(optIdx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryPurple.withOpacity(0.2) : AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? AppTheme.primaryPurple : AppTheme.textDimmed.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? AppTheme.primaryPurple : Colors.transparent,
                        border: Border.all(
                          color: selected ? AppTheme.primaryPurple : AppTheme.textDimmed,
                          width: 2,
                        ),
                      ),
                      child: selected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _options[optIdx],
                        style: TextStyle(
                          color: selected ? AppTheme.textWhite : AppTheme.textGrey,
                          fontSize: 15,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
