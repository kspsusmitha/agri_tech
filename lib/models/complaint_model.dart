class ComplaintModel {
  final String id;
  final String userId;
  final String userRole;
  final String title;
  final String description;
  final String status; // pending, resolved
  final String? resolution;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  ComplaintModel({
    required this.id,
    required this.userId,
    required this.userRole,
    required this.title,
    required this.description,
    this.status = 'pending',
    this.resolution,
    required this.createdAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userRole': userRole,
      'title': title,
      'description': description,
      'status': status,
      'resolution': resolution,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userRole: json['userRole'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      resolution: json['resolution'],
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
    );
  }
}

