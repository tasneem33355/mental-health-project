import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../data/app_state.dart';
import '../services/api_service.dart';

class MoodPatternsScreen extends StatefulWidget {
  const MoodPatternsScreen({super.key});

  @override
  State<MoodPatternsScreen> createState() => _MoodPatternsScreenState();
}

class _MoodPatternsScreenState extends State<MoodPatternsScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;
  late Future<List<MoodRecord>> _checkinHistoryFuture;
  int _selectedRangeDays = 7;

  @override
  void initState() {
    super.initState();
    _historyFuture = ApiService.getHistory();
    _checkinHistoryFuture = _loadCheckinHistory();
  }

  Future<List<MoodRecord>> _loadCheckinHistory() async {
    final data = await ApiService.getCheckinHistory();
    if (data.isEmpty) {
      return AppState.moodHistory;
    }
    return data
        .where((item) => item['created_at'] != null)
        .map((item) {
          final date = DateTime.tryParse(item['created_at'].toString());
          if (date == null) return null;
          return MoodRecord(
            date: date.toLocal(),
            stress: (item['mood'] as num).toInt(),
            energy: (item['energy'] as num).toDouble() / 10.0,
            sleep: (item['sleep'] as num).toInt(),
          );
        })
        .whereType<MoodRecord>()
        .toList();
  }

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
            _buildCheckinSection(),
            const SizedBox(height: 32),

            // Assessment History Graph
            const Text(
              'DASS 42 Assessment History',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildDassHistoryGraph(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDassHistoryGraph() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 250,
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple)),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 250,
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Could not load history:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.red),
              ),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return Container(
            height: 260,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.textDimmed.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_outlined, color: AppTheme.textDimmed, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'No assessments yet',
                  style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete a DASS-42 assessment to see your progress here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/assessment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple.withOpacity(0.2),
                    foregroundColor: AppTheme.accentPurple,
                    elevation: 0,
                  ),
                  child: const Text('Take Assessment'),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.textDimmed.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _legendItem('Depression', AppTheme.accentPurple),
                  _legendItem('Anxiety', AppTheme.orange),
                  _legendItem('Stress', AppTheme.green),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 14,
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
                            if (index >= 0 && index < data.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  data[index]['date'].toString(),
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
                          interval: 14,
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
                    maxX: (data.length - 1).toDouble(),
                    minY: 0,
                    maxY: 56, // Max DASS score with 5 options
                    lineBarsData: [
                      // Depression Line
                      _createDassLineData(data, 'depression', AppTheme.accentPurple),
                      // Anxiety Line
                      _createDassLineData(data, 'anxiety', AppTheme.orange),
                      // Stress Line
                      _createDassLineData(data, 'stress', AppTheme.green),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckinSection() {
    return FutureBuilder<List<MoodRecord>>(
      future: _checkinHistoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 300,
            padding: const EdgeInsets.fromLTRB(10, 24, 20, 10),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPurple),
            ),
          );
        }

        final history = snapshot.data ?? [];
        final filteredHistory = _filterByRange(history, _selectedRangeDays);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStreakCard(history),
            const SizedBox(height: 20),
            const Text(
              'Daily Check-ins',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildRangeSelector(),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 16),
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
                          if (index >= 0 && index < filteredHistory.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('E').format(filteredHistory[index].date),
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
                  maxX: filteredHistory.isEmpty ? 1 : (filteredHistory.length - 1).toDouble(),
                  minY: 0,
                  maxY: 4.5,
                  lineBarsData: filteredHistory.isEmpty
                      ? []
                      : [
                          _lineData(
                            filteredHistory
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value.stress.toDouble()))
                                .toList(),
                            AppTheme.red,
                          ),
                          _lineData(
                            filteredHistory
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value.energy * 4))
                                .toList(),
                            AppTheme.orange,
                          ),
                          _lineData(
                            filteredHistory
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value.sleep.toDouble()))
                                .toList(),
                            AppTheme.green,
                          ),
                        ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildInsights(filteredHistory),
          ],
        );
      },
    );
  }

  LineChartBarData _createDassLineData(List<dynamic> data, String key, Color color) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), (e.value[key] ?? 0).toDouble());
      }).toList(),
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

  Widget _buildRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _rangeChip(7),
        _rangeChip(14),
        _rangeChip(30),
      ],
    );
  }

  Widget _rangeChip(int days) {
    final selected = _selectedRangeDays == days;
    return GestureDetector(
      onTap: () => setState(() => _selectedRangeDays = days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryPurple.withOpacity(0.2) : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryPurple : AppTheme.textDimmed.withOpacity(0.2),
          ),
        ),
        child: Text(
          'Last $days days',
          style: TextStyle(
            color: selected ? AppTheme.textWhite : AppTheme.textGrey,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(List<MoodRecord> history) {
    final streak = _calculateStreak(history);
    return Container(
      width: double.infinity,
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
            child: const Icon(Icons.local_fire_department, color: AppTheme.accentPurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Check-in Streak',
                  style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  streak == 0 ? 'Start your streak today.' : '$streak day${streak == 1 ? '' : 's'} in a row.',
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStreak(List<MoodRecord> history) {
    if (history.isEmpty) return 0;
    final sorted = List<MoodRecord>.from(history)
      ..sort((a, b) => a.date.compareTo(b.date));
    int streak = 0;
    DateTime day = DateTime.now();
    for (int i = sorted.length - 1; i >= 0; i--) {
      final entryDay = DateTime(sorted[i].date.year, sorted[i].date.month, sorted[i].date.day);
      final targetDay = DateTime(day.year, day.month, day.day);
      if (entryDay == targetDay) {
        streak += 1;
        day = day.subtract(const Duration(days: 1));
      } else if (entryDay.isBefore(targetDay)) {
        break;
      }
    }
    return streak;
  }

  List<MoodRecord> _filterByRange(List<MoodRecord> history, int days) {
    if (history.isEmpty) return [];
    final start = DateTime.now().subtract(Duration(days: days - 1));
    return history.where((h) => h.date.isAfter(start) || _sameDay(h.date, start)).toList();
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
