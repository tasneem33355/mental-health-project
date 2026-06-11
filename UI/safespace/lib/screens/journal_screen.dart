import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_state.dart';
import '../services/api_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        title: const Text('Safe Journal', style: TextStyle(color: AppTheme.textWhite)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.accentPurple),
            onPressed: () async {
              final fullContent = _titleController.text.trim().isNotEmpty 
                  ? '${_titleController.text.trim()}\n\n${_controller.text.trim()}'
                  : _controller.text.trim();
              if (fullContent.isEmpty) return;
              await AppState.addJournalEntry(fullContent);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Journal entry saved privately.')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: AppState.refreshJournalEntries(),
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateTime.now().toString().split(' ')[0],
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'How are you really doing?',
                  style: TextStyle(color: AppTheme.textWhite, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: isWide
                      ? Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildEditor(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildLibrary(),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(child: _buildEditor()),
                            const SizedBox(height: 16),
                            SizedBox(height: 260, child: _buildLibrary()),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
      );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          style: const TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            hintText: 'Journal Title',
            hintStyle: TextStyle(color: AppTheme.textDimmed),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
        const Divider(color: AppTheme.textDimmed, height: 1),
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
    );
  }

  Widget _buildLibrary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Journal Library',
          style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AppState.journalEntries.isEmpty
              ? const Center(
                  child: Text(
                    'No entries yet',
                    style: TextStyle(color: AppTheme.textDimmed, fontSize: 12),
                  ),
                )
              : ListView.separated(
                  itemCount: AppState.journalEntries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = AppState.journalEntries[index];
                    return _JournalCard(
                      entry: entry,
                      onTap: () => _showEntryDetails(entry),
                      onEdit: () => _showEditDialog(entry),
                      onDelete: () => _confirmDelete(entry),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showEntryDetails(JournalEntry entry) async {
    final lines = entry.content.split('\n');
    final body = lines.length > 2 
        ? lines.sublist(2).join('\n') 
        : (lines.length > 1 ? lines.sublist(1).join('\n') : '');

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(_formatDate(entry.date), style: const TextStyle(color: AppTheme.textDimmed, fontSize: 12)),
              const SizedBox(height: 16),
              Text(body, style: const TextStyle(color: AppTheme.textGrey, fontSize: 14, height: 1.6)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(JournalEntry entry) async {
    if (entry.id == null) return;
    
    final lines = entry.content.split('\n');
    final title = lines.isNotEmpty ? lines.first : '';
    final body = lines.length > 2 
        ? lines.sublist(2).join('\n') 
        : (lines.length > 1 ? lines.sublist(1).join('\n') : '');

    final titleController = TextEditingController(text: title);
    final bodyController = TextEditingController(text: body);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Edit Entry', style: TextStyle(color: AppTheme.textWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: AppTheme.textDimmed),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: const InputDecoration(
                hintText: 'Content',
                hintStyle: TextStyle(color: AppTheme.textDimmed),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newFullContent = titleController.text.trim().isNotEmpty
                  ? '${titleController.text.trim()}\n\n${bodyController.text.trim()}'
                  : bodyController.text.trim();
              await ApiService.updateJournalEntry(
                entryId: entry.id!,
                content: newFullContent,
              );
              await AppState.refreshJournalEntries();
              if (!mounted) return;
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(JournalEntry entry) async {
    if (entry.id == null) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Delete Entry', style: TextStyle(color: AppTheme.textWhite)),
        content: const Text('This will remove the entry permanently.', style: TextStyle(color: AppTheme.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.deleteJournalEntry(entryId: entry.id!);
              await AppState.refreshJournalEntries();
              if (!mounted) return;
              Navigator.pop(ctx);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _JournalCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _JournalCard({
    required this.entry,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.textDimmed.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: const TextStyle(color: AppTheme.textDimmed, fontSize: 11)),
                Row(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, color: AppTheme.textDimmed, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: AppTheme.textDimmed, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(entry.title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(entry.preview, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
