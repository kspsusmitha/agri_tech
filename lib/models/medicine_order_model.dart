class MedicineOrderModel {
  final String id;
  final String medicineId;
  final String medicineName;
  final String farmerId;
  final String farmerName;
  final String sellerId;
  final double price;
  final int quantity;
  final double totalAmount;
  final String status; // pending, approved, dispatched, delivered, cancelled
  final DateTime createdAt;
  final String address;
  final String phone;

  MedicineOrderModel({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.farmerId,
    required this.farmerName,
    required this.sellerId,
    required this.price,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.address,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'sellerId': sellerId,
      'price': price,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'address': address,
      'phone': phone,
    };
  }

  factory MedicineOrderModel.fromJson(Map<String, dynamic> json) {
    return MedicineOrderModel(
      id: json['id'] ?? '',
      medicineId: json['medicineId'] ?? '',
      medicineName: json['medicineName'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      sellerId: json['sellerId'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
