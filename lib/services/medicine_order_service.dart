import 'package:firebase_database/firebase_database.dart';
import '../models/medicine_order_model.dart';

class MedicineOrderService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Place a new medicine order
  Future<void> placeOrder(MedicineOrderModel order) async {
    await _database
        .child('medicine_orders')
        .child(order.id)
        .set(order.toJson());
  }

  /// Stream orders for a specific seller
  Stream<List<MedicineOrderModel>> streamSellerOrders(String sellerId) {
    return _database.child('medicine_orders').onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.values
          .map((v) => MedicineOrderModel.fromJson(Map<String, dynamic>.from(v)))
          .where((o) => o.sellerId == sellerId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Stream orders for a specific farmer
  Stream<List<MedicineOrderModel>> streamFarmerOrders(String farmerId) {
    return _database.child('medicine_orders').onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.values
          .map((v) => MedicineOrderModel.fromJson(Map<String, dynamic>.from(v)))
          .where((o) => o.farmerId == farmerId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Stream all medicine orders (for Admin)
  Stream<List<MedicineOrderModel>> streamAllOrders() {
    return _database.child('medicine_orders').onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.values
          .map((v) => MedicineOrderModel.fromJson(Map<String, dynamic>.from(v)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _database.child('medicine_orders').child(orderId).update({
      'status': status,
    });
  }
}
