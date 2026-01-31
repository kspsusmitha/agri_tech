class ProductModel {
  final String id;
  final String farmerId;
  final String farmerName; // Farmer's username/name
  final String farmerEmail; // Farmer's email
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String unit; // kg, piece, etc.
  final String? imageBase64; // Base64 encoded image string (stored in Firestore)
  final String category;
  final String status; // pending, approved, rejected
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerEmail,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    this.imageBase64,
    required this.category,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerEmail': farmerEmail,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'imageBase64': imageBase64,
      'category': category,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      farmerEmail: json['farmerEmail'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? 'kg',
      imageBase64: json['imageBase64'],
      category: json['category'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] is String 
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as dynamic).toDate(),
    );
  }
  
  // Create a copy with updated fields
  ProductModel copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? farmerEmail,
    String? name,
    String? description,
    double? price,
    int? quantity,
    String? unit,
    String? imageUrl,
    String? category,
    String? status,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerEmail: farmerEmail ?? this.farmerEmail,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imageBase64: imageBase64 ?? this.imageBase64,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

