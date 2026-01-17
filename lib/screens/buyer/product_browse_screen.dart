import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'buyer_cart_screen.dart';

class ProductBrowseScreen extends StatefulWidget {
  const ProductBrowseScreen({super.key});

  @override
  State<ProductBrowseScreen> createState() => _ProductBrowseScreenState();
}

class _ProductBrowseScreenState extends State<ProductBrowseScreen> {
  String _selectedCategory = 'All';
  final List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    // Sample data
    _products.addAll([
      {
        'id': '1',
        'name': 'Fresh Tomatoes',
        'price': 2.50,
        'unit': 'kg',
        'category': 'Vegetables',
        'farmer': 'Farmer 1',
        'rating': 4.5,
      },
      {
        'id': '2',
        'name': 'Organic Wheat',
        'price': 1.80,
        'unit': 'kg',
        'category': 'Grains',
        'farmer': 'Farmer 2',
        'rating': 4.8,
      },
      {
        'id': '3',
        'name': 'Sweet Corn',
        'price': 3.00,
        'unit': 'piece',
        'category': 'Vegetables',
        'farmer': 'Farmer 1',
        'rating': 4.2,
      },
      {
        'id': '4',
        'name': 'Fresh Potatoes',
        'price': 1.50,
        'unit': 'kg',
        'category': 'Vegetables',
        'farmer': 'Farmer 3',
        'rating': 4.6,
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _selectedCategory == 'All'
        ? _products
        : _products.where((p) => p['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Products'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
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
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(filteredProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
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
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 48, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${product['farmer']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        product['rating'].toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product['price'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(AppConstants.primaryColorValue),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        iconSize: 20,
                        color: const Color(AppConstants.primaryColorValue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product['name']} added to cart'),
                            ),
                          );
                        },
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

  void _showProductDetails(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 64, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By ${product['farmer']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      product['rating'].toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fresh ${product['name'].toString().toLowerCase()} directly from the farm. '
                  'High quality produce with no pesticides.',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product['price'].toStringAsFixed(2)} / ${product['unit']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(AppConstants.primaryColorValue),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product['name']} added to cart'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppConstants.primaryColorValue),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

