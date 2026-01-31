import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class AdminService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Get system-wide statistics
  Stream<Map<String, int>> streamSystemStats() {
    return _database.onValue.map((event) {
      if (!event.snapshot.exists) {
        return {
          'totalFarmers': 0,
          'totalBuyers': 0,
          'totalMedicineSellers': 0,
          'pendingProducts': 0,
          'totalOrders': 0,
          'totalMedicineOrders': 0,
        };
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;

      // Count Users
      int farmers = 0;
      int buyers = 0;
      int medicineSellers = 0;
      if (data['users'] != null) {
        final usersRoleData = data['users'] as Map<dynamic, dynamic>;
        farmers = (usersRoleData['farmer'] as Map?)?.length ?? 0;
        buyers = (usersRoleData['buyer'] as Map?)?.length ?? 0;
        medicineSellers =
            (usersRoleData['medicine_seller'] as Map?)?.length ?? 0;
      }

      // Count Products
      int pending = 0;
      if (data['products'] != null) {
        final productsData = data['products'] as Map<dynamic, dynamic>;
        pending = productsData.values
            .where((p) => p['status'] == 'pending')
            .length;
      }

      // Count Orders
      int orders = 0;
      if (data['orders'] != null) {
        orders = (data['orders'] as Map).length;
      }

      int medicineOrders = 0;
      if (data['medicine_orders'] != null) {
        medicineOrders = (data['medicine_orders'] as Map).length;
      }

      return {
        'totalFarmers': farmers,
        'totalBuyers': buyers,
        'totalMedicineSellers': medicineSellers,
        'pendingProducts': pending,
        'totalOrders': orders,
        'totalMedicineOrders': medicineOrders,
      };
    });
  }

  /// Update system notification/alert
  Future<void> pushSystemAlert(String title, String message) async {
    try {
      final alertId = DateTime.now().millisecondsSinceEpoch.toString();
      await _database.child('system_alerts').child(alertId).set({
        'title': title,
        'message': message,
        'timestamp': ServerValue.timestamp,
      });
      debugPrint('✅ [Admin Service] System alert pushed: $title');
    } catch (e) {
      debugPrint('❌ [Admin Service] Push alert error: $e');
      rethrow;
    }
  }
}
