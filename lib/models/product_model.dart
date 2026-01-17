class ProductModel {
  final String id;
  final String farmerId;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String unit; // kg, piece, etc.
  final String? imageUrl;
  final String category;
  final String status; // pending, approved, rejected
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    this.imageUrl,
    required this.category,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'imageUrl': imageUrl,
      'category': category,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? 'kg',
      imageUrl: json['imageUrl'],
      category: json['category'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

