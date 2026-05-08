import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import '../services/api_service.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final history = await ApiService.getHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Wellness',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Mood Graph
            const Text(
              'Mood Tracker',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your DASS-42 scores over time directly from the database.',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 24),

            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple))
                : _history.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Take your first DASS-42 assessment to see your mood graph here!',
                            style: TextStyle(color: AppTheme.textGrey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Container(
                        height: 250,
                        padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: LineChart(_buildChartData()),
                      ),
            
            const SizedBox(height: 40),

            // Wellness Tools
            const Text(
              'Wellness Tools',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildToolCard('🌬️', 'Box Breathing', AppTheme.primaryPurple)),
                const SizedBox(width: 16),
                Expanded(child: _buildToolCard('⚓', '5-4-3-2-1 Grounding', AppTheme.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    List<FlSpot> depSpots = [];
    List<FlSpot> anxSpots = [];
    List<FlSpot> strSpots = [];

    for (int i = 0; i < _history.length; i++) {
      depSpots.add(FlSpot(i.toDouble(), (_history[i]['depression'] ?? 0).toDouble()));
      anxSpots.add(FlSpot(i.toDouble(), (_history[i]['anxiety'] ?? 0).toDouble()));
      strSpots.add(FlSpot(i.toDouble(), (_history[i]['stress'] ?? 0).toDouble()));
    }

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int idx = value.toInt();
              if (idx >= 0 && idx < _history.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_history[idx]['date'], style: const TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                );
              }
              return const Text('');
            },
            reservedSize: 22,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: depSpots,
          isCurved: true,
          color: AppTheme.primaryPurple,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
        ),
        LineChartBarData(
          spots: anxSpots,
          isCurved: true,
          color: AppTheme.orange,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
        ),
        LineChartBarData(
          spots: strSpots,
          isCurved: true,
          color: AppTheme.green,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
        ),
      ],
    );
  }

  Widget _buildToolCard(String emoji, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
