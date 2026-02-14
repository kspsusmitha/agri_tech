class MedicineModel {
  final String id;
  final String name;
  final String category; // Fertilizer, Pesticide, Fungicide
  final String targetDisease;
  final String instructions;
  final String providerName;
  final String providerUrl;
  final double price;
  final String? imageUrl;
  final String sellerId;
  final String status; // pending, approved, rejected
  final DateTime createdAt;

  MedicineModel({
    required this.id,
    required this.name,
    required this.category,
    required this.targetDisease,
    required this.instructions,
    required this.providerName,
    required this.providerUrl,
    required this.price,
    this.imageUrl,
    required this.sellerId,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'targetDisease': targetDisease,
      'instructions': instructions,
      'providerName': providerName,
      'providerUrl': providerUrl,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      targetDisease: json['targetDisease'] ?? '',
      instructions: json['instructions'] ?? '',
      providerName: json['providerName'] ?? '',
      providerUrl: json['providerUrl'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'],
      sellerId: json['sellerId'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] != null
                ? (json['createdAt'] as dynamic).toDate()
                : DateTime.now()),
    );
  }

  MedicineModel copyWith({
    String? id,
    String? name,
    String? category,
    String? targetDisease,
    String? instructions,
    String? providerName,
    String? providerUrl,
    double? price,
    String? imageUrl,
    String? sellerId,
    String? status,
    DateTime? createdAt,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      targetDisease: targetDisease ?? this.targetDisease,
      instructions: instructions ?? this.instructions,
      providerName: providerName ?? this.providerName,
      providerUrl: providerUrl ?? this.providerUrl,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
