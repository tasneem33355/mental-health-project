import 'package:flutter/material.dart';
import '../main.dart';

class ArticleScreen extends StatelessWidget {
  final String title;
  final String content;
  final String emoji;
  final Color color;

  const ArticleScreen({
    super.key,
    required this.title,
    required this.content,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: color.withOpacity(0.2),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 80)),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textWhite),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: const Text('Psychoeducation',
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    content,
                    style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 16,
                        height: 1.6),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.accentPurple),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'This article is for educational purposes. If you are feeling overwhelmed, please reach out to a professional.',
                            style: TextStyle(color: AppTheme.textDimmed, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
