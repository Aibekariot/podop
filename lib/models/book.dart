import 'chapter.dart';

enum BookStatus { idea, inProgress, completed }

extension BookStatusExtension on BookStatus {
  String get title {
    switch (this) {
      case BookStatus.idea:
        return 'Идея';

      case BookStatus.inProgress:
        return 'В процессе';

      case BookStatus.completed:
        return 'Завершена';
    }
  }

  String get icon {
    switch (this) {
      case BookStatus.idea:
        return '💡';

      case BookStatus.inProgress:
        return '✍️';

      case BookStatus.completed:
        return '📖';
    }
  }
}

class Book {
  String title;
  String author;
  String genre;
  String description;
  DateTime createdAt;
  BookStatus status;
  String? imagePath;
  List<Chapter> chapters;

  Book({
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
    required this.createdAt,
    required this.status,
    this.imagePath,
    List<Chapter>? chapters,
  }) : chapters = chapters ?? [];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'genre': genre,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'imagePath': imagePath,
      'chapters': chapters.map((chapter) {
        return chapter.toJson();
      }).toList(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      genre: json['genre'] ?? 'Фэнтези',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      status: BookStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => BookStatus.idea,
      ),
      imagePath: json['imagePath'],
      chapters: (json['chapters'] as List<dynamic>? ?? []).map((chapter) {
        return Chapter.fromJson(Map<String, dynamic>.from(chapter));
      }).toList(),
    );
  }
}