import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';

class BookStorage {
  static const String _booksKey = 'books';

  Future<void> saveBooks(List<Book> books) async {
    final preferences = await SharedPreferences.getInstance();

    final booksJson = books.map((book) {
      return book.toJson();
    }).toList();

    await preferences.setString(
      _booksKey,
      jsonEncode(booksJson),
    );
  }

  Future<List<Book>> loadBooks() async {
    final preferences = await SharedPreferences.getInstance();

    final booksString = preferences.getString(_booksKey);

    if (booksString == null || booksString.isEmpty) {
      return [];
    }

    final List<dynamic> booksJson = jsonDecode(booksString);

    return booksJson.map((json) {
      return Book.fromJson(
        Map<String, dynamic>.from(json),
      );
    }).toList();
  }

  Future<void> saveBook(Book book) async {
    final books = await loadBooks();

    final index = books.indexWhere(
      (item) =>
          item.title == book.title &&
          item.createdAt == book.createdAt,
    );

    if (index != -1) {
      books[index] = book;
    } else {
      books.add(book);
    }

    await saveBooks(books);
  }

  Future<void> clearBooks() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_booksKey);
  }
}