import 'package:flutter/material.dart';
import '../main.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _controller = TextEditingController();

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
          ],
        ),
      ),
    );
  }
}
