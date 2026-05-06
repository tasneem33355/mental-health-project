import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../data/app_state.dart';

class MoodPatternsScreen extends StatelessWidget {
  const MoodPatternsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = AppState.moodHistory;

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
        title: const Text('Mood Tracking',
            style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Here's your wellness journey over the past week.",
              style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Legend
            _buildLegend(),
            const SizedBox(height: 16),

            // Main Graph Container
            Container(
              height: 300,
              padding: const EdgeInsets.fromLTRB(10, 24, 20, 10),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppTheme.textDimmed.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < history.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('E').format(history[index].date),
                                style: const TextStyle(color: AppTheme.textDimmed, fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(color: AppTheme.textDimmed, fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (history.length - 1).toDouble(),
                  minY: 0,
                  maxY: 4.5,
                  lineBarsData: [
                    // Stress Level (0-4)
                    _lineData(
                      history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.stress.toDouble())).toList(),
                      AppTheme.red,
                    ),
                    // Energy Level (0.0-1.0 mapped to 0-4)
                    _lineData(
                      history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.energy * 4)).toList(),
                      AppTheme.orange,
                    ),
                    // Sleep Quality (0-4)
                    _lineData(
                      history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.sleep.toDouble())).toList(),
                      AppTheme.green,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            _buildInsights(history),
          ],
        ),
      ),
    );
  }

  LineChartBarData _lineData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeWidth: 2,
          strokeColor: AppTheme.bgCard,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendItem('Stress', AppTheme.red),
        _legendItem('Energy', AppTheme.orange),
        _legendItem('Sleep', AppTheme.green),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppTheme.textWhite, fontSize: 12)),
      ],
    );
  }

  Widget _buildInsights(List<MoodRecord> history) {
    if (history.isEmpty) return const SizedBox();
    
    final last = history.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Insights',
            style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        _insightCard(
          'Mood Summary',
          'Your energy has been ${last.energy > 0.7 ? 'high' : 'stable'} today. ${last.stress > 2 ? 'Try some breathing exercises to lower your stress.' : 'You seem to be in a calm state.'}',
          Icons.auto_awesome,
        ),
      ],
    );
  }

  Widget _insightCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentPurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
