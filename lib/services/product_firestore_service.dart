import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  /// Add a new product to Firestore
  Future<Map<String, dynamic>> addProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).set(product.toJson());
      debugPrint('✅ [Product Firestore] Product added: ${product.id}');
      debugPrint('   Farmer: ${product.farmerName} (${product.farmerEmail})');
      return {
        'success': true,
        'message': 'Product added successfully',
      };
    } catch (e) {
      debugPrint('❌ [Product Firestore] Add product error: $e');
      return {
        'success': false,
        'message': 'Failed to add product: ${e.toString()}',
      };
    }
  }

  /// Get all products for a specific farmer (by farmerId)
  Future<List<ProductModel>> getFarmerProducts(String farmerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('createdAt', descending: true)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      debugPrint('✅ [Product Firestore] Loaded ${products.length} products for farmer: $farmerId');
      return products;
    } catch (e) {
      debugPrint('❌ [Product Firestore] Get farmer products error: $e');
      return [];
    }
  }

  /// Get all products for a specific farmer by email
  Future<List<ProductModel>> getFarmerProductsByEmail(String farmerEmail) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('farmerEmail', isEqualTo: farmerEmail.toLowerCase().trim())
          .orderBy('createdAt', descending: true)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      debugPrint('✅ [Product Firestore] Loaded ${products.length} products for farmer email: $farmerEmail');
      return products;
    } catch (e) {
      debugPrint('❌ [Product Firestore] Get farmer products by email error: $e');
      return [];
    }
  }

  /// Get all approved products (for buyers to browse)
  Future<List<ProductModel>> getAllApprovedProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      debugPrint('✅ [Product Firestore] Loaded ${products.length} approved products');
      return products;
    } catch (e) {
      debugPrint('❌ [Product Firestore] Get approved products error: $e');
      return [];
    }
  }

  /// Get all pending products (for admin approval)
  Future<List<ProductModel>> getPendingProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: false)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      debugPrint('✅ [Product Firestore] Loaded ${products.length} pending products');
      return products;
    } catch (e) {
      debugPrint('❌ [Product Firestore] Get pending products error: $e');
      return [];
    }
  }

  /// Update product
  Future<Map<String, dynamic>> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).update(product.toJson());
      debugPrint('✅ [Product Firestore] Product updated: ${product.id}');
      return {
        'success': true,
        'message': 'Product updated successfully',
      };
    } catch (e) {
      debugPrint('❌ [Product Firestore] Update product error: $e');
      return {
        'success': false,
        'message': 'Failed to update product: ${e.toString()}',
      };
    }
  }

  /// Delete product
  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
      debugPrint('✅ [Product Firestore] Product deleted: $productId');
      return {
        'success': true,
        'message': 'Product deleted successfully',
      };
    } catch (e) {
      debugPrint('❌ [Product Firestore] Delete product error: $e');
      return {
        'success': false,
        'message': 'Failed to delete product: ${e.toString()}',
      };
    }
  }

  /// Update product status (for admin approval)
  Future<Map<String, dynamic>> updateProductStatus(
    String productId,
    String status,
  ) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'status': status,
      });
      debugPrint('✅ [Product Firestore] Product status updated: $productId -> $status');
      return {
        'success': true,
        'message': 'Product status updated successfully',
      };
    } catch (e) {
      debugPrint('❌ [Product Firestore] Update status error: $e');
      return {
        'success': false,
        'message': 'Failed to update status: ${e.toString()}',
      };
    }
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(productId).get();
      
      if (!doc.exists) {
        return null;
      }

      return ProductModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      debugPrint('❌ [Product Firestore] Get product by ID error: $e');
      return null;
    }
  }

  /// Stream products for a farmer (real-time updates)
  Stream<List<ProductModel>> streamFarmerProducts(String farmerId) {
    return _firestore
        .collection(_collection)
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  /// Stream all approved products (for buyers)
  Stream<List<ProductModel>> streamApprovedProducts() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }
}
