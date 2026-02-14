class OrderModel {
  final String id;
  final String buyerId;
  final String farmerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String
  status; // pending, approved, processing, shipped, delivered, cancelled
  final String? shippingAddress;
  final DateTime createdAt;
  final DateTime? deliveryDate;
  final String? rating;
  final String? feedback;
  final DateTime? reviewedAt;
  final String? paymentId;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    this.shippingAddress,
    required this.createdAt,
    this.deliveryDate,
    this.rating,
    this.feedback,
    this.reviewedAt,
    this.paymentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'farmerId': farmerId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'shippingAddress': shippingAddress,
      'createdAt': createdAt.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'rating': rating,
      'feedback': feedback,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'paymentId': paymentId,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      buyerId: json['buyerId'] ?? '',
      farmerId: json['farmerId'] ?? '',
      items:
          (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      shippingAddress: json['shippingAddress'],
      createdAt: DateTime.parse(json['createdAt']),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      rating: json['rating'],
      feedback: json['feedback'],
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      paymentId: json['paymentId'],
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }
}
