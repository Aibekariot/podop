import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/chapter.dart';

class ChapterEditorScreen extends StatefulWidget {
  final Book book;
  final Chapter? chapter;

  const ChapterEditorScreen({
    super.key,
    required this.book,
    this.chapter,
  });

  bool get isEditing => chapter != null;

  @override
  State<ChapterEditorScreen> createState() => _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends State<ChapterEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.chapter != null) {
      _titleController.text = widget.chapter!.title;
      _contentController.text = widget.chapter!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveChapter() {
    final title = _titleController.text.trim();
    final content = _contentController.text;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите название главы'),
        ),
      );
      return;
    }

    final now = DateTime.now();

    // Редактирование существующей главы
    if (widget.chapter != null) {
      final chapter = widget.chapter!;

      chapter.title = title;
      chapter.content = content;
      chapter.updatedAt = now;

      Navigator.pop(context, chapter);
      return;
    }

    // Создание новой главы
    final chapter = Chapter(
      title: title,
      content: content,
      number: widget.book.chapters.length + 1,
      createdAt: now,
      updatedAt: now,
    );

    Navigator.pop(context, chapter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Редактирование главы' : 'Новая глава',
        ),
        actions: [
          IconButton(
            onPressed: _saveChapter,
            icon: const Icon(Icons.save),
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название главы',
                hintText: 'Например: Глава 1. Начало',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Текст главы',
                  hintText: 'Начните писать текст...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveChapter,
                icon: const Icon(Icons.save),
                label: const Text('Сохранить главу'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}