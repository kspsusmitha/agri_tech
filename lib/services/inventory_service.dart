import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/inventory_model.dart';

class InventoryService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Add or update an inventory item
  Future<void> updateInventoryItem(InventoryModel item) async {
    try {
      await _database
          .child('inventory')
          .child(item.farmerId)
          .child(item.id)
          .set(item.toJson());
      debugPrint('✅ [Inventory Service] Item updated: ${item.itemName}');
    } catch (e) {
      debugPrint('❌ [Inventory Service] Update item error: $e');
      rethrow;
    }
  }

  /// Stream inventory items for a farmer
  Stream<List<InventoryModel>> streamInventory(String farmerId) {
    return _database.child('inventory').child(farmerId).onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.values
          .map((v) => InventoryModel.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    });
  }

  /// Delete an inventory item
  Future<void> deleteItem(String farmerId, String itemId) async {
    await _database.child('inventory').child(farmerId).child(itemId).remove();
  }

  /// Get low stock items
  Stream<List<InventoryModel>> streamLowStockItems(String farmerId) {
    return streamInventory(farmerId).map((items) {
      return items.where((item) => item.quantity <= item.minThreshold).toList();
    });
  }

  /// Record stock usage/addition
  Future<void> updateStockQuantity(
    String farmerId,
    String itemId,
    double change,
  ) async {
    final ref = _database
        .child('inventory')
        .child(farmerId)
        .child(itemId)
        .child('quantity');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      double current = (snapshot.value as num).toDouble();
      await ref.set(current + change);
    }
  }
}
