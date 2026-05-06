import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../main.dart';
import '../services/api_service.dart';

class NlpPredictionScreen extends StatefulWidget {
  const NlpPredictionScreen({super.key});

  @override
  State<NlpPredictionScreen> createState() => _NlpPredictionScreenState();
}

class _NlpPredictionScreenState extends State<NlpPredictionScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isLoading = false;
  Map<String, dynamic>? _predictionResults;
  String? _error;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _textCtrl.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _analyzeText() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _predictionResults = null;
    });

    try {
      // Send the text along with dummy survey answers (since the endpoint requires it)
      // The backend returns separate 'text_scores' which we will display directly.
      final response = await ApiService.analyzeMentalHealth(text, List.filled(42, 0));
      
      setState(() {
        _predictionResults = response['text_scores'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('NLP Text Analysis', style: TextStyle(color: AppTheme.textWhite)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Text Analysis',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Powered by our custom NLP mental health model. Express your feelings, and our model will analyze the text for indicators of Depression, Anxiety, or Stress.',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Type or speak your thoughts:', style: TextStyle(color: AppTheme.textGrey)),
                  GestureDetector(
                    onTap: _listen,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isListening ? AppTheme.red.withOpacity(0.2) : AppTheme.primaryPurple.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? AppTheme.red : AppTheme.accentPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.textDimmed.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: _textCtrl,
                  maxLines: 6,
                  style: const TextStyle(color: AppTheme.textWhite),
                  decoration: const InputDecoration(
                    hintText: 'Type how you feel right now in Arabic or English...',
                    hintStyle: TextStyle(color: AppTheme.textDimmed),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _analyzeText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Analyze Text', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),

              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('Error: $_error', style: const TextStyle(color: AppTheme.red)),
                ),

              if (_predictionResults != null) ...[
                const Text(
                  'Analysis Results',
                  style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildResultBar('Depression', _predictionResults!['depression']?.toDouble() ?? 0.0, AppTheme.accentPurple),
                const SizedBox(height: 16),
                _buildResultBar('Anxiety', _predictionResults!['anxiety']?.toDouble() ?? 0.0, AppTheme.orange),
                const SizedBox(height: 16),
                _buildResultBar('Stress', _predictionResults!['stress']?.toDouble() ?? 0.0, AppTheme.green),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.textDimmed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'These scores are raw probabilities from the NLP text model. A higher percentage indicates stronger semantic correlation with the condition.',
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultBar(String label, double probability, Color color) {
    int percentage = (probability * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
            Text('$percentage%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: probability,
            minHeight: 10,
            backgroundColor: AppTheme.bgCard,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
