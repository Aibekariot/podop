import 'dart:io';

import 'package:flutter/material.dart';

import '../models/book.dart';
import '../screens/book_detail_screen.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onChanged;
  final VoidCallback? onDeleted;

  const BookCard({
    super.key,
    required this.book,
    this.onChanged,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(book: book),
            ),
          );

          if (result == 'deleted') {
            onChanged?.call();
            onDeleted?.call();
            return;
          }

          if (result is Book) {
            onChanged?.call();
          }
        },

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // Обложка
              Container(
                width: 90,
                height: 125,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.deepPurple.shade100,
                ),

                clipBehavior: Clip.antiAlias,

                child: book.imagePath == null
                    ? const Icon(Icons.menu_book, size: 45)
                    : Image.file(File(book.imagePath!), fit: BoxFit.cover),
              ),

              const SizedBox(width: 16),

              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      book.title,

                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      book.author,

                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      book.genre,

                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        '${book.status.icon} ${book.status.title}',

                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
