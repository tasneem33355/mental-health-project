import 'package:flutter/material.dart';
import '../main.dart';

class AssessmentIntroScreen extends StatelessWidget {
  const AssessmentIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
              ),
              const SizedBox(height: 32),
              
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.psychology,
                      color: AppTheme.accentPurple,
                      size: 64,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              const Text(
                'Full Wellbeing Analysis',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'A comprehensive look at your mental health using AI and clinical standards.',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              _buildInfoRow(
                Icons.history_edu_outlined,
                'Reflective Analysis',
                'Start by sharing your current feelings in your own words. Our AI analyzes your sentiment for deeper insight.',
              ),
              const SizedBox(height: 24),
              _buildInfoRow(
                Icons.assignment_turned_in_outlined,
                'DASS-42 Standard',
                'Answer 42 questions from the clinically validated Depression, Anxiety, and Stress Scale.',
              ),
              const SizedBox(height: 24),
              _buildInfoRow(
                Icons.timer_outlined,
                '10 Minute Duration',
                'Take your time to answer honestly. You cannot skip questions once you start.',
              ),
              
              const SizedBox(height: 60),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/assessment-start'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Analysis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Your privacy is our priority. All data is analyzed securely.',
                  style: TextStyle(color: AppTheme.textDimmed, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.accentPurple, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
