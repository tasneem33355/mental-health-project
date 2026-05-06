import 'package:flutter/material.dart';
import '../main.dart';

class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override
  State<GroundingScreen> createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen> {
  int _currentStep = 5;
  final Set<String> _selectedItems = {};
  bool _isFinished = false;

  final Map<int, Map<String, dynamic>> _stepData = {
    5: {
      'instruction': 'Name 5 things you can SEE',
      'hint': 'Look around you',
      'emoji': '👀',
      'options': ['Phone', 'Desk', 'Window', 'Light', 'Book', 'Door', 'Clock', 'Plant'],
      'target': 5,
    },
    4: {
      'instruction': 'Name 4 things you can FEEL',
      'hint': 'Notice your body and surroundings',
      'emoji': '🖐️',
      'options': ['Chair', 'Feet on floor', 'Clothes', 'Hands', 'Air', 'Phone in hand', 'Texture', 'Warmth'],
      'target': 4,
    },
    3: {
      'instruction': 'Name 3 things you can HEAR',
      'hint': 'Listen closely',
      'emoji': '👂',
      'options': ['Traffic', 'Fan/AC', 'Birds', 'Breathing', 'Typing', 'Voices', 'Clock ticking', 'Silence'],
      'target': 3,
    },
    2: {
      'instruction': 'Name 2 things you can SMELL',
      'hint': 'Breathe in deep',
      'emoji': '👃',
      'options': ['Coffee', 'Air', 'Food', 'Paper', 'Soap', 'Plants', 'Perfume', 'Nothing'],
      'target': 2,
    },
    1: {
      'instruction': 'Name 1 thing you can TASTE',
      'hint': 'Focus on your mouth',
      'emoji': '👅',
      'options': ['Water', 'Mint', 'Last meal', 'Tea', 'Coffee', 'Toothpaste', 'Gum', 'Nothing'],
      'target': 1,
    },
  };

  void _onChipTapped(String option) {
    if (_isFinished) return;
    
    setState(() {
      if (_selectedItems.contains(option)) {
        _selectedItems.remove(option);
      } else {
        if (_selectedItems.length < _stepData[_currentStep]!['target']) {
          _selectedItems.add(option);
        }
      }
    });
  }

  void _nextStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
        _selectedItems.clear();
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _stepData[_currentStep]!;
    final int target = step['target'];
    final bool canContinue = _selectedItems.length >= target;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('5-4-3-2-1 Grounding', style: TextStyle(color: AppTheme.textWhite, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _isFinished ? _buildSuccessState() : _buildGameState(step, target, canContinue),
        ),
      ),
    );
  }

  Widget _buildGameState(Map<String, dynamic> step, int target, bool canContinue) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Progress Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [5, 4, 3, 2, 1].map((s) {
            bool isCurrent = s == _currentStep;
            bool isPast = s > _currentStep;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Text(
                    '$s',
                    style: TextStyle(
                      color: isCurrent ? AppTheme.accentPurple : (isPast ? AppTheme.green : AppTheme.textDimmed),
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCurrent ? AppTheme.accentPurple : (isPast ? AppTheme.green : AppTheme.bgCardLight),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const Spacer(flex: 1),
        // Main Instruction
        Text(
          step['emoji'],
          style: const TextStyle(fontSize: 60),
        ),
        const SizedBox(height: 24),
        Text(
          step['instruction'],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          step['hint'],
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 16),
        ),
        const SizedBox(height: 40),
        // Selection Counter
        Text(
          '${_selectedItems.length} / $target',
          style: TextStyle(
            color: canContinue ? AppTheme.green : AppTheme.accentPurple,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        // Chips Area
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ...(step['options'] as List<String>).map((opt) {
                  bool isSelected = _selectedItems.contains(opt);
                  return GestureDetector(
                    onTap: () => _onChipTapped(opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryPurple : AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryPurple : AppTheme.textDimmed.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) const Icon(Icons.check, size: 16, color: Colors.white),
                          if (isSelected) const SizedBox(width: 8),
                          Text(
                            opt,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textGrey,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                _buildAddOwnChip(),
              ],
            ),
          ),
        ),
        // Bottom Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canContinue ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: canContinue ? AppTheme.primaryPurple : AppTheme.bgCardLight,
            ),
            child: Text(
              _currentStep == 1 ? 'Finish' : 'Continue',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAddOwnChip() {
    return GestureDetector(
      onTap: () {
        // Just a mock for now, adding a random item or just showing the functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom input coming soon! Tap existing chips for now.'), duration: Duration(seconds: 1)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.accentPurple.withOpacity(0.5), style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: AppTheme.accentPurple),
            SizedBox(width: 8),
            Text('Add your own', style: TextStyle(color: AppTheme.accentPurple)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌿', style: TextStyle(fontSize: 100)),
          const SizedBox(height: 32),
          const Text(
            'You’re grounded',
            style: TextStyle(color: AppTheme.textWhite, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'You did a great job returning to the present moment.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
          ),
          const SizedBox(height: 64),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textGrey,
                side: const BorderSide(color: AppTheme.textDimmed),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Reflection'),
            ),
          ),
        ],
      ),
    );
  }
}
