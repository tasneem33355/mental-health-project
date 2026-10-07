import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import '../localization.dart';

class DassResultsScreen extends StatelessWidget {
  final Map<String, int> scores;
  final Map<String, dynamic>? apiResult;

  const DassResultsScreen({super.key, required this.scores, this.apiResult});

  String _getLevel(String type, int score) {
    double percentage = (score / 42) * 100;
    if (percentage < 30) return 'Normal';
    if (percentage < 45) return 'Mild';
    if (percentage < 60) return 'Moderate';
    if (percentage < 75) return 'Severe';
    return 'Extremely Severe';
  }

  Color _getColor(String level) {
    switch (level) {
      case 'Normal':
        return AppTheme.green;
      case 'Mild':
        return const Color(0xFFD4AF37);
      case 'Moderate':
        return const Color(0xFFB85D19);
      case 'Severe':
        return const Color(0xFF8B2323);
      case 'Extremely Severe':
        return const Color(0xFFFF0000);
      default:
        return AppTheme.textGrey;
    }
  }

  String _formatLabel(String raw) {
    return raw.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Extract recommendations from API result
    final recommendations = apiResult?['recommendations'];
    final tipsEn = (recommendations?['tips_en'] as List?)?.cast<String>() ?? [];
    final resourcesEn =
        (recommendations?['resources_en'] as List?)?.cast<String>() ?? [];
    final referralEn = recommendations?['referral_en'] as String? ?? '';
    final suicidalFlag = apiResult?['suicidal_flag'] as bool? ?? false;
    final primaryCondition = apiResult?['primary_condition'] as String?;
    final severity = apiResult?['severity'] as String?;
    final cause = apiResult?['cause'] as String?;
    final surveyScores = apiResult?['survey_scores'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Your Assessment Results'.tr,
            style: TextStyle(color: AppTheme.textWhite)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Based on your answers, here is your current emotional state profile:'.tr,
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
                  border: Border.all(
                      color: AppTheme.red.withOpacity(0.5), width: 2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppTheme.red, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Please Reach Out for Help'.tr,
                            style: TextStyle(
                                color: AppTheme.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your responses indicate you may need immediate support. Please contact a mental health professional or crisis helpline.'.tr,
                            style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 13,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (suicidalFlag)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.red.withOpacity(0.5), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crisis Support'.tr,
                      style: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (referralEn.isNotEmpty)
                      Text(
                        referralEn,
                        style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 13,
                            height: 1.4),
                      ),
                    if (resourcesEn.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Reach out now:'.tr,
                        style:
                            TextStyle(color: AppTheme.textGrey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      ...resourcesEn
                          .map((resource) => _buildResourceCard(resource)),
                    ],
                  ],
                ),
              ),

            if (primaryCondition != null || severity != null || cause != null)
              _buildAiSummaryGrid(primaryCondition, severity, cause),
            const SizedBox(height: 24),
            _buildAiModelProfile(surveyScores, scores),
            const SizedBox(height: 32),

            // Recommendations Section
            if (tipsEn.isNotEmpty) ...[
              Text(
                'Personalized Tips'.tr,
                style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...tipsEn.map((tip) => _buildTipCard(tip)),
              const SizedBox(height: 24),
            ],

            // Resources Section
            if (resourcesEn.isNotEmpty) ...[
              Text(
                'Helpful Resources'.tr,
                style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
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
                  border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_hospital_outlined,
                        color: AppTheme.accentPurple, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Professional Guidance'.tr,
                            style: TextStyle(
                                color: AppTheme.textWhite,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            referralEn,
                            style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 13,
                                height: 1.4),
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
            Text(
              'What does this mean?'.tr,
              style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'These scales measure the intensity of emotional states. They are not a clinical diagnosis but a way to help you understand your feelings better.'.tr,
              style: TextStyle(
                  color: AppTheme.textGrey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back to Home'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTipCard(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppTheme.yellow, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.yellow.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb_outline, color: AppTheme.yellow, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                tip,
                style: TextStyle(color: AppTheme.textWhite, fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(String resource) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.bgCard, AppTheme.bgCardLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.menu_book_rounded, color: AppTheme.accentPurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                resource,
                style: TextStyle(color: AppTheme.textWhite, fontSize: 15, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiModelProfile(Map<String, dynamic>? surveyScores, Map<String, int> fallbackScores) {
    bool hasAi = surveyScores != null && surveyScores.isNotEmpty;

    double depPercent = hasAi ? (surveyScores['depression'] as num).toDouble() * 100 : (fallbackScores['Depression'] ?? 0) / 42 * 100;
    double anxPercent = hasAi ? (surveyScores['anxiety'] as num).toDouble() * 100 : (fallbackScores['Anxiety'] ?? 0) / 42 * 100;
    double strPercent = hasAi ? (surveyScores['stress'] as num).toDouble() * 100 : (fallbackScores['Stress'] ?? 0) / 42 * 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.textDimmed.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(hasAi ? Icons.psychology : Icons.calculate_outlined, color: AppTheme.textWhite, size: 24),
              const SizedBox(width: 8),
              Text(
                hasAi ? 'AI Pattern Recognition'.tr : 'Clinical Profile'.tr,
                style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasAi ? 'Probability based on your response patterns compared to thousands of clinical surveys.'.tr : 'Percentage of maximum intensity for each category.'.tr,
            style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 24),
          _buildAiProfileBar('Depression', depPercent),
          const SizedBox(height: 24),
          _buildAiProfileBar('Anxiety', anxPercent),
          const SizedBox(height: 24),
          _buildAiProfileBar('Stress', strPercent),
        ],
      ),
    );
  }

  Widget _buildAiProfileBar(String title, double percentage) {
    int fakeScore = (percentage / 100 * 42).round();
    final level = _getLevel(title, fakeScore);
    final color = _getColor(level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(color: AppTheme.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  level,
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppTheme.bgDark,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
      ],
    );
  }


  Widget _buildAiSummaryGrid(
      String? primaryCondition, String? severity, String? cause) {
    final items = [
      _SummaryTile(
        label: 'Primary Focus'.tr,
        value: primaryCondition != null ? _formatLabel(primaryCondition) : '—',
        color: AppTheme.accentPurple,
        icon: Icons.psychology_alt,
      ),
      _SummaryTile(
        label: 'Severity'.tr,
        value: severity != null ? _formatLabel(severity) : '—',
        color: AppTheme.orange,
        icon: Icons.warning_amber_rounded,
      ),
      _SummaryTile(
        label: 'Root Cause'.tr,
        value: cause != null ? _formatLabel(cause) : '—',
        color: AppTheme.green,
        icon: Icons.explore_outlined,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentPurple.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.accentPurple, size: 24),
              const SizedBox(width: 10),
              Text(
                'AI Analysis Summary'.tr,
                style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _summaryCard(items[0], const EdgeInsets.only(right: 12)),
              _summaryCard(items[1], const EdgeInsets.only(right: 12)),
              _summaryCard(items[2], EdgeInsets.zero),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(_SummaryTile item, EdgeInsets margin) {
    return Expanded(
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              item.label.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textGrey, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              item.value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
}
