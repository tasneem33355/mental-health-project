import 'package:flutter/material.dart';
import '../main.dart';

class DassResultsScreen extends StatelessWidget {
  final Map<String, int> scores;
  final Map<String, dynamic>? apiResult;

  const DassResultsScreen({super.key, required this.scores, this.apiResult});

  String _getLevel(String type, int score) {
    if (type == 'Depression') {
      if (score <= 9) return 'Normal';
      if (score <= 13) return 'Mild';
      if (score <= 20) return 'Moderate';
      if (score <= 27) return 'Severe';
      return 'Extremely Severe';
    } else if (type == 'Anxiety') {
      if (score <= 7) return 'Normal';
      if (score <= 9) return 'Mild';
      if (score <= 14) return 'Moderate';
      if (score <= 19) return 'Severe';
      return 'Extremely Severe';
    } else { // Stress
      if (score <= 14) return 'Normal';
      if (score <= 18) return 'Mild';
      if (score <= 25) return 'Moderate';
      if (score <= 33) return 'Severe';
      return 'Extremely Severe';
    }
  }

  Color _getColor(String level) {
    switch (level) {
      case 'Normal': return AppTheme.green;
      case 'Mild': return Colors.yellow;
      case 'Moderate': return AppTheme.orange;
      case 'Severe': return AppTheme.red;
      case 'Extremely Severe': return const Color(0xFF8B0000);
      default: return AppTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract recommendations from API result
    final recommendations = apiResult?['recommendations'];
    final tipsEn = (recommendations?['tips_en'] as List?)?.cast<String>() ?? [];
    final resourcesEn = (recommendations?['resources_en'] as List?)?.cast<String>() ?? [];
    final referralEn = recommendations?['referral_en'] as String? ?? '';
    final suicidalFlag = apiResult?['suicidal_flag'] as bool? ?? false;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Assessment Results', style: TextStyle(color: AppTheme.textWhite)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Based on your answers, here is your current emotional state profile:',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Suicidal crisis warning
            if (suicidalFlag)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.red.withOpacity(0.5), width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppTheme.red, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Please Reach Out for Help',
                            style: TextStyle(color: AppTheme.red, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your responses indicate you may need immediate support. Please contact a mental health professional or crisis helpline.',
                            style: TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            _buildResultCard('Depression', scores['Depression'] ?? 0),
            const SizedBox(height: 20),
            _buildResultCard('Anxiety', scores['Anxiety'] ?? 0),
            const SizedBox(height: 20),
            _buildResultCard('Stress', scores['Stress'] ?? 0),
            const SizedBox(height: 32),

            // Recommendations Section
            if (tipsEn.isNotEmpty) ...[
              const Text(
                'Personalized Tips',
                style: TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...tipsEn.map((tip) => _buildTipCard(tip)),
              const SizedBox(height: 24),
            ],

            // Resources Section
            if (resourcesEn.isNotEmpty) ...[
              const Text(
                'Helpful Resources',
                style: TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...resourcesEn.map((resource) => _buildResourceCard(resource)),
              const SizedBox(height: 24),
            ],

            // Referral Section
            if (referralEn.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_hospital_outlined, color: AppTheme.accentPurple, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Professional Guidance',
                            style: TextStyle(color: AppTheme.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            referralEn,
                            style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // What does this mean section
            const Text(
              'What does this mean?',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'These scales measure the intensity of emotional states. They are not a clinical diagnosis but a way to help you understand your feelings better.',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: const Icon(Icons.lightbulb_outline, color: AppTheme.yellow, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(String resource) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: const Icon(Icons.menu_book_outlined, color: AppTheme.accentPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              resource,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, int score) {
    final level = _getLevel(title, score);
    final color = _getColor(level);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Text(
                  level,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: score / 56, // Max possible score is 56 per scale (14 * 4 with 5 options)
                    backgroundColor: AppTheme.bgDark,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$score/56',
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
