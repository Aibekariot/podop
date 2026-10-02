import 'dart:io';

import 'package:flutter/material.dart';

import '../models/book.dart';
import 'add_book_screen.dart';
import 'chapters_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('О книге')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Обложка
            Center(
              child: Container(
                width: 190,
                height: 270,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.deepPurple.shade100,
                ),
                clipBehavior: Clip.antiAlias,
                child: book.imagePath == null
                    ? const Icon(Icons.menu_book, size: 70)
                    : Image.file(File(book.imagePath!), fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 28),

            // Название
            Text(
              book.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Автор
            Text(
              book.author,
              style: TextStyle(fontSize: 17, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 20),

            // Жанр и статус
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(icon: Icons.category, text: book.genre),
                _InfoChip(
                  icon: Icons.flag,
                  text: '${book.status.icon} ${book.status.title}',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Дата создания
            const Text(
              'Дата создания',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              _formatDate(book.createdAt),
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 24),

            // Описание
            const Text(
              'Описание',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              book.description.isEmpty
                  ? 'Описание отсутствует.'
                  : book.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 30),

            // КНОПКА РЕДАКТИРОВАТЬ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<Book>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChaptersScreen(book: book),
                    ),
                  );

                  if (result != null && context.mounted) {
                    Navigator.pop(context, result);
                  }
                },
                icon: const Icon(Icons.menu_book),
                label: Text('Главы (${book.chapters.length})'),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<Book>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddBookScreen(book: book),
                    ),
                  );

                  if (result != null && context.mounted) {
                    Navigator.pop(context, result);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Редактировать'),
              ),
            ),

            const SizedBox(height: 12),

            // КНОПКА УДАЛИТЬ
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Удалить книгу?'),
                        content: const Text(
                          'Вы действительно хотите удалить эту книгу? '
                          'Это действие нельзя отменить.',
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

                  if (confirmed == true && context.mounted) {
                    Navigator.pop(context, 'deleted');
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Удалить книгу'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(text)],
      ),
    );
  }
}
