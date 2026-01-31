class VideoModel {
  final String id;
  final String title;
  final String
  category; // Organic Farming, Pest Control, Machinery, Best Practices
  final String videoUrl;
  final String? thumbnailUrl;
  final String? description;
  final DateTime createdAt;

  VideoModel({
    required this.id,
    required this.title,
    required this.category,
    required this.videoUrl,
    this.thumbnailUrl,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
