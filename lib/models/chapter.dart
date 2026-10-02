class Chapter {
  String title;
  String content;
  int number;
  DateTime createdAt;
  DateTime updatedAt;

  Chapter({
    required this.title,
    required this.content,
    required this.number,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'number': number,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      number: json['number'] ?? 1,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}