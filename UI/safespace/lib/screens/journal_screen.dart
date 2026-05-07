import 'package:flutter/material.dart';
import '../main.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_JournalEntry> _entries = [
    _JournalEntry(
      date: DateTime.now().subtract(const Duration(days: 1)),
      title: 'A quieter day',
      preview: 'I kept things simple today. Walked, hydrated, and felt more grounded.',
    ),
    _JournalEntry(
      date: DateTime.now().subtract(const Duration(days: 3)),
      title: 'Overthinking spiral',
      preview: 'Work stress spiked. I paused, wrote my thoughts, and felt lighter after.',
    ),
    _JournalEntry(
      date: DateTime.now().subtract(const Duration(days: 6)),
      title: 'Small wins',
      preview: 'Completed tasks I kept avoiding. Energy felt steady in the evening.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        title: const Text('Safe Journal', style: TextStyle(color: AppTheme.textWhite)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.accentPurple),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Journal entry saved privately.')),
              );
            },
          ),
        ],
      ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTime.now().toString().split(' ')[0],
                style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'How are you really doing?',
                style: TextStyle(color: AppTheme.textWhite, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(color: AppTheme.textWhite, fontSize: 16, height: 1.6),
                        decoration: const InputDecoration(
                          hintText: 'Start writing your thoughts here...',
                          hintStyle: TextStyle(color: AppTheme.textDimmed),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Journal Library',
                            style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.separated(
                              itemCount: _entries.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final entry = _entries[index];
                                return _JournalCard(entry: entry);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class _JournalEntry {
  final DateTime date;
  final String title;
  final String preview;

  const _JournalEntry({
    required this.date,
    required this.title,
    required this.preview,
  });
}

class _JournalCard extends StatelessWidget {
  final _JournalEntry entry;

  const _JournalCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final date = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.textDimmed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(color: AppTheme.textDimmed, fontSize: 11)),
          const SizedBox(height: 8),
          Text(entry.title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(entry.preview, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}
