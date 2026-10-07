import 'package:flutter/material.dart';
import '../main.dart';
import '../data/dass_questions.dart';
import '../data/app_state.dart';
import '../services/api_service.dart';
import 'dass_results_screen.dart';
import '../localization.dart';

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

  List<String> get _options => [
    'Did not apply to me at all'.tr,
    'Applied to me to some degree'.tr,
    'Applied to me to a considerable degree'.tr,
    'Applied to me very much'.tr,
  ];

  void _onOptionSelected(int questionIndex, int value) {
    setState(() {
      _answers[questionIndex] = value;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentIndex < dassQuestions.length) {
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
        SnackBar(content: Text('Please write how you feel before submitting.'.tr)),
      );
      return;
    }

    if (_answers.length < dassQuestions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all questions'.tr),
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
      builder: (context) => Center(
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
    double progress = _currentIndex == 0 ? 0.0 : _currentIndex / dassQuestions.length;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Full Assessment'.tr,
              style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Text + DASS-42'.tr,
              style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
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
                      _currentIndex == 0 ? 'Reflection'.tr : '${'Question'.tr} $_currentIndex ${'of'.tr} ${dassQuestions.length}',
                      style: TextStyle(
                        color: AppTheme.accentPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.bgCardLight,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
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
              itemCount: dassQuestions.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntroCard(),
                        const SizedBox(height: 16),
                        _buildTextCard(),
                      ],
                    ),
                  );
                } else {
                  final qIndex = index - 1;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildQuestionCard(dassQuestions[qIndex].text.tr, qIndex),
                  );
                }
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
                    icon: Icon(Icons.arrow_back, color: AppTheme.accentPurple),
                    label: Text('Previous'.tr, style: TextStyle(color: AppTheme.accentPurple)),
                  )
                else
                  const SizedBox(),
                if (_currentIndex == 0)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text('Next'.tr),
                  )
                else if (_currentIndex == dassQuestions.length)
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text('Finish'.tr),
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
          Text(
            'How are you feeling right now?'.tr,
            style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Write in Arabic or English. The survey works better with longer sentences, so describe your feeling more fully.'.tr,
            style: TextStyle(color: AppTheme.textGrey, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 4,
            style: TextStyle(color: AppTheme.textWhite),
            decoration: InputDecoration(
              hintText: 'Type how you feel...'.tr
            ),
          ),
          const SizedBox(height: 16),
          Text('Quick Examples (Tap to paste):'.tr, style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _exampleChip('AR - اكتئاب شديد', 'انا مكتئب جدا ومش لاقي معنى للحياة. حياتي خربت وخسرت كل حاجة. مش عايز أصحى من النوم'),
              _exampleChip('AR - قلق جامعي', 'انا قلقان جدا من الامتحان. خايف ارسب ومش عارف اذاكر. الجامعة ضغط كبير عليا'),
              _exampleChip('AR - ضغط الشغل', 'ضغط الشغل كتير عليا. مش لاقي وقت لنفسي ومديري بيضغط عليا كل يوم. تعبت نفسياً'),
              _exampleChip('EN - Depression', 'I feel completely hopeless and exhausted. I have no motivation to get out of bed and nothing brings me joy anymore.'),
              _exampleChip('EN - Work Stress', 'Work has been overwhelming. I feel like I\'m constantly drowning in tasks and my boss keeps pressuring me.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _exampleChip(String label, String text) {
    return ActionChip(
      label: Text(label, style: TextStyle(color: AppTheme.accentPurple, fontSize: 11)),
      backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
      side: BorderSide(color: AppTheme.primaryPurple.withOpacity(0.3)),
      onPressed: () {
        setState(() {
          _textController.text = text;
        });
      },
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textDimmed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Brief'.tr,
            style: TextStyle(color: AppTheme.textWhite, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'This assessment combines your written reflection with 42 questions. It helps you understand your mood patterns, not a medical diagnosis.'.tr,
            style: TextStyle(color: AppTheme.textGrey, fontSize: 12, height: 1.4),
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
          child: Icon(Icons.psychology_outlined, color: AppTheme.accentPurple),
        ),
        const SizedBox(height: 24),
        Text(
          text,
          style: TextStyle(
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
              onTap: () => _onOptionSelected(index, optIdx),
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
