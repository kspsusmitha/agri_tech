class InventoryModel {
  final String id;
  final String farmerId;
  final String itemName;
  final String category; // Seeds, Fertilizers, Tools, Products
  final double quantity;
  final String unit; // kg, liters, units
  final double minThreshold;
  final DateTime? expiryDate;
  final DateTime lastUpdated;

  InventoryModel({
    required this.id,
    required this.farmerId,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    this.minThreshold = 5.0,
    this.expiryDate,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'itemName': itemName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'minThreshold': minThreshold,
      'expiryDate': expiryDate?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      itemName: json['itemName'] ?? '',
      category: json['category'] ?? '',
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      minThreshold: (json['minThreshold'] ?? 5.0).toDouble(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
