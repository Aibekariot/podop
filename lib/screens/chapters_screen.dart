import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/chapter.dart';
import 'chapter_editor_screen.dart';
import 'chapter_reader_screen.dart';
import '../services/book_storage.dart';

class ChaptersScreen extends StatefulWidget {
  final Book book;

  const ChaptersScreen({super.key, required this.book});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  final BookStorage _storage = BookStorage();

  @override
  Widget build(BuildContext context) {
    final chapters = widget.book.chapters;

    return PopScope<Book>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        Navigator.pop(context, widget.book);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Главы')),
        body: chapters.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book, size: 70),
                    SizedBox(height: 16),
                    Text(
                      'В этой книге пока нет глав',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Добавьте первую главу'),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapter = chapters[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${chapter.number}')),
                      title: Text(
                        chapter.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${chapter.content.length} символов'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'read':
                              _openChapter(index);
                              break;

                            case 'edit':
                              _editChapter(chapter);
                              break;

                            case 'delete':
                              _deleteChapter(chapter);
                              break;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'read',
                            child: Row(
                              children: [
                                Icon(Icons.menu_book),
                                SizedBox(width: 10),
                                Text('Читать'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 10),
                                Text('Редактировать'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline),
                                SizedBox(width: 10),
                                Text('Удалить'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _openChapter(index);
                      },
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addChapter,
          icon: const Icon(Icons.add),
          label: const Text('Добавить главу'),
        ),
      ),
    );
  }

  Future<void> _addChapter() async {
    final chapter = await Navigator.push<Chapter>(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterEditorScreen(book: widget.book),
      ),
    );

    if (chapter == null || !mounted) {
      return;
    }

    setState(() {
      widget.book.chapters.add(chapter);
    });

    await _storage.saveBook(widget.book);
  }

  Future<void> _editChapter(Chapter chapter) async {
    final result = await Navigator.push<Chapter>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChapterEditorScreen(book: widget.book, chapter: chapter),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {});
  }

  void _openChapter(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChapterReaderScreen(book: widget.book, chapterIndex: index),
      ),
    );
  }

  Future<void> _deleteChapter(Chapter chapter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить главу?'),
          content: Text(
            'Вы действительно хотите удалить главу '
            '«${chapter.title}»?\n\n'
            'Текст главы будет удалён. Это действие нельзя отменить.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      widget.book.chapters.remove(chapter);

      for (int i = 0; i < widget.book.chapters.length; i++) {
        widget.book.chapters[i].number = i + 1;
      }
    });

    await _storage.saveBook(widget.book);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Глава удалена')));
  }
}
