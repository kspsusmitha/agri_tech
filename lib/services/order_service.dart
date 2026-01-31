import 'package:firebase_database/firebase_database.dart';
import '../models/order_model.dart';

class OrderService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Place a new order
  Future<void> placeOrder(OrderModel order) async {
    await _database.child('orders').child(order.id).set(order.toJson());
  }

  // Stream orders for a specific buyer
  Stream<List<OrderModel>> streamBuyerOrders(String buyerId) {
    return _database
        .child('orders')
        .orderByChild('buyerId')
        .equalTo(buyerId)
        .onValue
        .map((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return [];

          final orders = data.entries.map((e) {
            return OrderModel.fromJson(
              Map<String, dynamic>.from(e.value as Map),
            );
          }).toList();

          // Sort by creation date descending
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  // Update order status (used by Farmer/Admin)
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _database.child('orders').child(orderId).update({
      'status': status,
      if (status == 'delivered')
        'deliveryDate': DateTime.now().toIso8601String(),
    });
  }

  // Submit review for an order
  Future<void> submitReview(
    String orderId,
    double rating,
    String feedback,
  ) async {
    await _database.child('orders').child(orderId).update({
      'rating': rating,
      'feedback': feedback,
      'reviewedAt': DateTime.now().toIso8601String(),
    });

    // Also update the product's average rating (simplified logic here)
    // In a real app, you'd aggregate ratings in a separate node
  }
}
