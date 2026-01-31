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
    );
  }
}
