import 'package:firebase_database/firebase_database.dart';
import '../models/product_model.dart';

class CartService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get cart reference for a buyer
  DatabaseReference _cartRef(String buyerId) =>
      _database.child('carts').child(buyerId);

  // Add item to cart
  Future<void> addToCart(
    String buyerId,
    ProductModel product,
    int quantity,
  ) async {
    final ref = _cartRef(buyerId).child(product.id);
    final snapshot = await ref.get();

    if (snapshot.exists) {
      // Update existing quantity
      final currentQty = (snapshot.value as Map)['quantity'] as int;
      await ref.update({'quantity': currentQty + quantity});
    } else {
      // Add new item
      await ref.set({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'quantity': quantity,
        'unit': product.unit,
        'farmerId': product.farmerId,
        'farmerName': product.farmerName,
        'imageBase64': product.imageBase64,
        'imageUrl': product.imageUrl,
      });
    }
  }

  // Update quantity
  Future<void> updateQuantity(
    String buyerId,
    String productId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await removeFromCart(buyerId, productId);
    } else {
      await _cartRef(buyerId).child(productId).update({'quantity': quantity});
    }
  }

  // Remove item
  Future<void> removeFromCart(String buyerId, String productId) async {
    await _cartRef(buyerId).child(productId).remove();
  }

  // Stream cart items
  Stream<List<Map<String, dynamic>>> streamCartItems(String buyerId) {
    return _cartRef(buyerId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.entries.map((e) {
        return Map<String, dynamic>.from(e.value as Map);
      }).toList();
    });
  }

  // Clear cart
  Future<void> clearCart(String buyerId) async {
    await _cartRef(buyerId).remove();
  }
}
