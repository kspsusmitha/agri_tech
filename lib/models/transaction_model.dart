class TransactionModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String buyerId;
  final String buyerName;
  final String productName;
  final double amount;
  final String status; // completed, pending, cancelled
  final String? invoiceUrl;
  final String paymentMethod;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.buyerId,
    required this.buyerName,
    required this.productName,
    required this.amount,
    required this.status,
    this.invoiceUrl,
    required this.paymentMethod,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'productName': productName,
      'amount': amount,
      'status': status,
      'invoiceUrl': invoiceUrl,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? 'Unknown',
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? 'Unknown',
      productName: json['productName'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      invoiceUrl: json['invoiceUrl'],
      paymentMethod: json['paymentMethod'] ?? 'COD',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
