import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductService {
  // Use the same database URL as configured in firebase_options.dart

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  ProductService() {
    debugPrint('✅ [Product Service] Database initialized');
  }

  /// Add a new product
  Future<Map<String, dynamic>> addProduct(ProductModel product) async {
    try {
      await _database.child('products').child(product.id).set(product.toJson());
      debugPrint('✅ [Product Service] Product added: ${product.id}');
      return {'success': true, 'message': 'Product added successfully'};
    } catch (e) {
      debugPrint('❌ [Product Service] Add product error: $e');
      return {
        'success': false,
        'message': 'Failed to add product: ${e.toString()}',
      };
    }
  }

  /// Get all products for a specific farmer
  Future<List<ProductModel>> getFarmerProducts(String farmerId) async {
    try {
      final snapshot = await _database.child('products').get();

      if (!snapshot.exists) {
        return [];
      }

      final productsData = snapshot.value as Map<dynamic, dynamic>;
      final List<ProductModel> products = [];

      productsData.forEach((key, value) {
        final productData = Map<String, dynamic>.from(value);
        if (productData['farmerId'] == farmerId) {
          products.add(ProductModel.fromJson(productData));
        }
      });

      // Sort by createdAt (newest first)
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint(
        '✅ [Product Service] Loaded ${products.length} products for farmer: $farmerId',
      );
      return products;
    } catch (e) {
      debugPrint('❌ [Product Service] Get farmer products error: $e');
      return [];
    }
  }

  /// Get all approved products (for buyers to browse)
  Future<List<ProductModel>> getAllApprovedProducts() async {
    try {
      final snapshot = await _database.child('products').get();

      if (!snapshot.exists) {
        return [];
      }

      final productsData = snapshot.value as Map<dynamic, dynamic>;
      final List<ProductModel> products = [];

      productsData.forEach((key, value) {
        final productData = Map<String, dynamic>.from(value);
        if (productData['status'] == 'approved') {
          products.add(ProductModel.fromJson(productData));
        }
      });

      // Sort by createdAt (newest first)
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint(
        '✅ [Product Service] Loaded ${products.length} approved products',
      );
      return products;
    } catch (e) {
      debugPrint('❌ [Product Service] Get approved products error: $e');
      return [];
    }
  }

  /// Get all pending products (for admin approval)
  Future<List<ProductModel>> getPendingProducts() async {
    try {
      final snapshot = await _database.child('products').get();

      if (!snapshot.exists) {
        return [];
      }

      final productsData = snapshot.value as Map<dynamic, dynamic>;
      final List<ProductModel> products = [];

      productsData.forEach((key, value) {
        final productData = Map<String, dynamic>.from(value);
        if (productData['status'] == 'pending') {
          products.add(ProductModel.fromJson(productData));
        }
      });

      // Sort by createdAt (oldest first for admin review)
      products.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      debugPrint(
        '✅ [Product Service] Loaded ${products.length} pending products',
      );
      return products;
    } catch (e) {
      debugPrint('❌ [Product Service] Get pending products error: $e');
      return [];
    }
  }

  /// Update product
  Future<Map<String, dynamic>> updateProduct(ProductModel product) async {
    try {
      await _database
          .child('products')
          .child(product.id)
          .update(product.toJson());
      debugPrint('✅ [Product Service] Product updated: ${product.id}');
      return {'success': true, 'message': 'Product updated successfully'};
    } catch (e) {
      debugPrint('❌ [Product Service] Update product error: $e');
      return {
        'success': false,
        'message': 'Failed to update product: ${e.toString()}',
      };
    }
  }

  /// Delete product
  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      await _database.child('products').child(productId).remove();
      debugPrint('✅ [Product Service] Product deleted: $productId');
      return {'success': true, 'message': 'Product deleted successfully'};
    } catch (e) {
      debugPrint('❌ [Product Service] Delete product error: $e');
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
      await _database.child('products').child(productId).update({
        'status': status,
      });
      debugPrint(
        '✅ [Product Service] Product status updated: $productId -> $status',
      );
      return {
        'success': true,
        'message': 'Product status updated successfully',
      };
    } catch (e) {
      debugPrint('❌ [Product Service] Update status error: $e');
      return {
        'success': false,
        'message': 'Failed to update status: ${e.toString()}',
      };
    }
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final snapshot = await _database.child('products').child(productId).get();

      if (!snapshot.exists) {
        return null;
      }

      final productData = Map<String, dynamic>.from(snapshot.value as Map);
      return ProductModel.fromJson(productData);
    } catch (e) {
      debugPrint('❌ [Product Service] Get product by ID error: $e');
      return null;
    }
  }

  /// Stream products for a farmer (real-time updates)
  Stream<List<ProductModel>> streamFarmerProducts(String farmerId) {
    return _database.child('products').onValue.map((event) {
      if (!event.snapshot.exists) {
        return <ProductModel>[];
      }

      final productsData = event.snapshot.value as Map<dynamic, dynamic>;
      final List<ProductModel> products = [];

      productsData.forEach((key, value) {
        final productData = Map<String, dynamic>.from(value);
        if (productData['farmerId'] == farmerId) {
          products.add(ProductModel.fromJson(productData));
        }
      });

      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }

  /// Stream all products for admin oversight
  Stream<List<ProductModel>> streamAllProducts() {
    return _database.child('products').onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final productsData = event.snapshot.value as Map<dynamic, dynamic>;
      final List<ProductModel> products = productsData.values
          .map((v) => ProductModel.fromJson(Map<String, dynamic>.from(v)))
          .toList();

      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }

  /// Stream approved products for buyers
  Stream<List<ProductModel>> streamApprovedProducts() {
    return _database.child('products').onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final productsData = event.snapshot.value as Map<dynamic, dynamic>;
      final List<ProductModel> products = [];

      productsData.forEach((key, value) {
        final productData = Map<String, dynamic>.from(value);
        if (productData['status'] == 'approved') {
          products.add(ProductModel.fromJson(productData));
        }
      });

      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }
}
