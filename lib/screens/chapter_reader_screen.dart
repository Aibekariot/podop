import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/chapter.dart';

class ChapterReaderScreen extends StatefulWidget {
  final Book book;
  final int chapterIndex;

  const ChapterReaderScreen({
    super.key,
    required this.book,
    required this.chapterIndex,
  });

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.chapterIndex;

    _pageController = PageController(initialPage: widget.chapterIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapters = widget.book.chapters;

    if (chapters.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Чтение')),
        body: const Center(child: Text('В книге пока нет глав')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Чтение')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: chapters.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final chapter = chapters[index];

                  return _ChapterPage(chapter: chapter);
                },
              ),
            ),

            // Индикатор текущей главы
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_currentIndex + 1} / ${chapters.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
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

class _ChapterPage extends StatelessWidget {
  final Chapter chapter;

  const _ChapterPage({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Номер главы
          Text(
            'Глава ${chapter.number}',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 8),

          // Название главы
          Text(
            chapter.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 28),

          // Текст главы
          Text(
            chapter.content.isEmpty
                ? 'В этой главе пока нет текста.'
                : chapter.content,
            style: const TextStyle(fontSize: 18, height: 1.8),
          ),
        ],
      ),
    );
  }
}
