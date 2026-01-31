class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final String category; // Notes, Help Desk, Land Posting
  final String? imageUrl;
  final List<String> likes;
  final List<Map<String, dynamic>> replies;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    this.likes = const [],
    this.replies = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'likes': likes,
      'replies': replies,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'Notes',
      imageUrl: json['imageUrl'],
      likes: List<String>.from(json['likes'] ?? []),
      replies: List<Map<String, dynamic>>.from(json['replies'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
