import 'package:flutter/material.dart';

import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../../services/session_service.dart';
import '../../models/product_model.dart';
import 'dart:convert';
import 'buyer_cart_screen.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_detail_screen.dart';

class ProductBrowseScreen extends StatefulWidget {
  const ProductBrowseScreen({super.key});

  @override
  State<ProductBrowseScreen> createState() => _ProductBrowseScreenState();
}

class _ProductBrowseScreenState extends State<ProductBrowseScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final String _buyerId = SessionService().user?.id ?? 'guest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Farmer\'s Market',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _cartService.streamCartItems(_buyerId),
            builder: (context, snapshot) {
              final cartCount = snapshot.data?.length ?? 0;
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.white,
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            cartCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BuyerCartScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.transparent, // Allow parent background to show
      body: Column(
        children: [
          const SizedBox(height: kToolbarHeight + 20), // Space for AppBar
          _buildSearchBarGlass(),
          _buildCategoryFilterGlass(),
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _productService.streamApprovedProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final products = snapshot.data ?? [];
                final filteredProducts = products.where((p) {
                  final matchesCategory =
                      _selectedCategory == 'All' ||
                      p.category == _selectedCategory;
                  final matchesSearch = p.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'No products found.',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) =>
                      _buildProductCardGlass(filteredProducts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarGlass() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        borderRadius: 20,
        child: TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search fresh produce...',
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterGlass() {
    final categories = ['All', 'Vegetables', 'Fruits', 'Grains', 'Dairy'];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: GlassContainer(
                borderRadius: 25,
                color: isSelected ? Colors.white30 : Colors.white10,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Text(
                    category,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCardGlass(ProductModel product) {
    return GlassContainer(
      borderRadius: 24,
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white10),
                    child: product.imageBase64 != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            child: Image.memory(
                              base64Decode(product.imageBase64!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.eco_rounded,
                              size: 48,
                              color: Colors.white24,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      borderRadius: 10,
                      child: Text(
                        '₹${product.price}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'by ${product.farmerName}',
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        child: IconButton(
                          icon: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _cartService.addToCart(_buyerId, product, 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}
