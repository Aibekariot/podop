import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/book.dart';

class AddBookScreen extends StatefulWidget {
  final Book? book;

  const AddBookScreen({super.key, this.book});

  bool get isEditing => book != null;

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  @override
  void initState() {
    super.initState();

    final book = widget.book;

    if (book != null) {
      _titleController.text = book.title;
      _authorController.text = book.author;
      _descriptionController.text = book.description;

      _selectedGenre = book.genre;
      _selectedStatus = book.status;
      _imagePath = book.imagePath;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _imagePath = image.path;
    });
  }

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedGenre = 'Фэнтези';

  BookStatus _selectedStatus = BookStatus.idea;

  String? _imagePath;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _saveBook() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.book != null) {
      widget.book!
        ..title = _titleController.text.trim()
        ..author = _authorController.text.trim()
        ..genre = _selectedGenre
        ..description = _descriptionController.text.trim()
        ..status = _selectedStatus
        ..imagePath = _imagePath;

      Navigator.pop(context, widget.book);
      return;
    }

    final book = Book(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      genre: _selectedGenre,
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      status: _selectedStatus,
      imagePath: _imagePath,
    );

    Navigator.pop(context, book);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Редактировать книгу' : 'Добавить книгу',
        ),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,

                child: Container(
                  width: 150,
                  height: 210,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.deepPurple.shade100,
                  ),

                  clipBehavior: Clip.antiAlias,

                  child: _imagePath == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(Icons.add_photo_alternate, size: 45),

                            SizedBox(height: 8),

                            Text('Добавить обложку'),
                          ],
                        )
                      : Image.file(File(_imagePath!), fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Создание книги',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // Название
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название книги',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите название книги';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // Автор
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Автор',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите имя автора';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // Жанр
            DropdownButtonFormField<String>(
              initialValue: _selectedGenre,

              decoration: const InputDecoration(
                labelText: 'Жанр',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),

              items: const [
                DropdownMenuItem(value: 'Фэнтези', child: Text('Фэнтези')),
                DropdownMenuItem(value: 'Детектив', child: Text('Детектив')),
                DropdownMenuItem(value: 'Роман', child: Text('Роман')),
                DropdownMenuItem(
                  value: 'Фантастика',
                  child: Text('Фантастика'),
                ),
                DropdownMenuItem(value: 'Ужасы', child: Text('Ужасы')),
                DropdownMenuItem(
                  value: 'Приключения',
                  child: Text('Приключения'),
                ),
                DropdownMenuItem(value: 'Другое', child: Text('Другое')),
              ],

              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGenre = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Статус
            DropdownButtonFormField<BookStatus>(
              initialValue: _selectedStatus,

              decoration: const InputDecoration(
                labelText: 'Статус книги',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),

              items: BookStatus.values.map((status) {
                return DropdownMenuItem<BookStatus>(
                  value: status,

                  child: Text('${status.icon} ${status.title}'),
                );
              }).toList(),

              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Описание
            TextFormField(
              controller: _descriptionController,

              maxLines: 5,

              decoration: const InputDecoration(
                labelText: 'Описание',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),

            const SizedBox(height: 24),

            // Кнопка
            SizedBox(
              height: 52,

              child: ElevatedButton.icon(
                onPressed: _saveBook,

                icon: const Icon(Icons.save),

                label: const Text(
                  'Сохранить книгу',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
