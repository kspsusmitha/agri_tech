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
  final String?
  imageBase64; // Base64 encoded image string (stored in Firestore)
  final String? imageUrl; // Network image URL (for recommended medicines)
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
    this.imageUrl,
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
      farmerName: json['farmerName'] ?? '',
      farmerEmail: json['farmerEmail'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? 'kg',
      imageBase64: json['imageBase64'],
      imageUrl: json['imageUrl'],
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
    String? imageBase64,
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
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Factory to create ProductModel from MedicineModel
  factory ProductModel.fromMedicine(dynamic medicine) {
    // Assuming medicine is MedicineModel (using dynamic to avoid circular import if needed,
    // or just import it. Since this is a model file, importing another model is fine if no cycle.
    // However, to keep it simple and avoid modifying imports heavily, I'll assume explicit mapping at call site
    // OR just define it with the type if I import it.
    // I will use implicit typing for the argument to avoid import issues for now, or add the import.
    // Let's check imports. ProductModel has no imports. MedicineModel has none.
    // I should add import if I use the type. Or just map manually in the screen.
    // The plan said "Add factory ProductModel.fromMedicine".
    // I'll stick to manual mapping in the screen if I don't import.
    // But factory is cleaner. I'll add the factory and use loose typing or add the import.
    // Let's add the factory logic.
    return ProductModel(
      id: medicine.id,
      farmerId: medicine.sellerId,
      farmerName: medicine.providerName,
      farmerEmail: '', // Not available in MedicineModel
      name: medicine.name,
      description: medicine.instructions,
      price: medicine.price,
      quantity: 1, // Default
      unit: 'unit', // Default
      imageBase64: null,
      imageUrl: medicine.imageUrl,
      category: medicine.category,
      status: 'approved',
      createdAt: DateTime.now(),
    );
  }
}
