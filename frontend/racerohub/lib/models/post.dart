class Post {
  final int id;
  final String title;
  final String content;
  final String? image;
  final DateTime? date;
  final int? authorId;
  final String? authorName;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    this.date,
    this.authorId,
    this.authorName,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final rawDate = json['date'];
    if (rawDate is String && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate);
    }

    final author = json['author'];
    int? authorId;
    String? authorName;
    if (author is Map<String, dynamic>) {
      authorId = author['id'];
      authorName = author['name'] ?? author['username'];
    }

    return Post(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      image: json['image'] as String?,
      date: parsedDate,
      authorId: authorId,
      authorName: authorName,
    );
  }
}
