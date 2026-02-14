import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../services/session_service.dart';
import '../../widgets/glass_widgets.dart';
import '../../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'buyer_cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final buyerId = SessionService().user?.id ?? 'guest';
    final CartService cartService = CartService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          product.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BuyerCartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1615811361523-6bd03c7799a4?auto=format&fit=crop&q=80&w=1920', // Abstract/Nature
        gradient: AppConstants.deepBlueGradient,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kToolbarHeight + 20),
              // Hero Image Section
              Hero(
                tag: 'product_image_${product.id}',
                child: Container(
                  height: 350,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: product.imageBase64 != null
                        ? Image.memory(
                            base64Decode(product.imageBase64!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.white10,
                                  child: const Icon(
                                    Icons.image_not_supported_rounded,
                                    size: 60,
                                    color: Colors.white24,
                                  ),
                                ),
                          )
                        : product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(
                                '❌ Error loading product image URL: ${product.imageUrl}',
                              );
                              debugPrint('Error details: $error');
                              return Container(
                                color: Colors.white10,
                                child: const Icon(
                                  Icons.broken_image_rounded,
                                  size: 60,
                                  color: Colors.white24,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.white10,
                            child: const Icon(
                              Icons.eco_rounded,
                              size: 80,
                              color: Colors.white24,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Details Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassContainer(
                  borderRadius: 30,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_pin_circle_rounded,
                                      size: 16,
                                      color: Colors.white60,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.farmerName,
                                      style: GoogleFonts.inter(
                                        color: Colors.white60,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                AppConstants.primaryColorValue,
                              ).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '₹${product.price}',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description.isEmpty
                            ? 'Fresh organic produce directly from the farm to your table. Grown with care and sustainable practices.'
                            : product.description,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.category_rounded,
                            product.category,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.scale_rounded,
                            '${product.quantity} ${product.unit} available',
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            cartService.addToCart(buyerId, product, 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_bag_rounded),
                          label: Text(
                            'Add to Cart',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
