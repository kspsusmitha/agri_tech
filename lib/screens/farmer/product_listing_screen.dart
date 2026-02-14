import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/image_service.dart';
import '../../services/session_service.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final ProductService _productService = ProductService();
  final ImageService _imageService = ImageService();
  final SessionService _sessionService = SessionService();

  // Search and filter controllers
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  String? _farmerId;
  String? _farmerName;
  String? _farmerEmail;

  @override
  void initState() {
    super.initState();
    final currentUser = _sessionService.getCurrentUser();
    _farmerId = currentUser?.id;
    _farmerName = currentUser?.name;
    _farmerEmail = currentUser?.email;
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'My Products',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1615811361523-6bd03c7799a4?auto=format&fit=crop&q=80&w=1920', // Vegetables/Produce
        gradient: AppConstants.primaryGradient,
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 40),
            _buildSearchAndFilterBar(),
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _productService.streamFarmerProducts(_farmerId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white24),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final products = snapshot.data ?? [];

                  // Filter products locally based on search/category/status
                  final filteredProducts = products.where((product) {
                    final query = _searchController.text.toLowerCase();
                    final matchesSearch =
                        query.isEmpty ||
                        product.name.toLowerCase().contains(query) ||
                        product.description.toLowerCase().contains(query);

                    final matchesCategory =
                        _selectedCategory == 'All' ||
                        product.category == _selectedCategory;

                    final matchesStatus =
                        _selectedStatus == 'All' ||
                        product.status == _selectedStatus.toLowerCase();

                    return matchesSearch && matchesCategory && matchesStatus;
                  }).toList();

                  if (filteredProducts.isEmpty && products.isEmpty) {
                    return _buildEmptyState();
                  } else if (filteredProducts.isEmpty) {
                    return Center(
                      child: Text(
                        'No products match your filter',
                        style: GoogleFonts.inter(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(filteredProducts[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: GlassContainer(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_rounded, size: 80, color: Colors.white30),
              const SizedBox(height: 20),
              Text(
                'No products listed yet',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showAddProductDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('LIST YOUR FIRST PRODUCT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(AppConstants.primaryColorValue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Search bar
          GlassContainer(
            padding: EdgeInsets.zero,
            borderRadius: 16,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          Row(
            children: [
              Expanded(
                child: _buildGlassDropdown(
                  value: _selectedCategory,
                  label: 'Category',
                  items: [
                    'All',
                    'Vegetables',
                    'Fruits',
                    'Grains',
                    'Dairy',
                    'Other',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGlassDropdown(
                  value: _selectedStatus,
                  label: 'Status',
                  items: ['All', 'Pending', 'Approved', 'Rejected'],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassDropdown({
    required String value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      borderRadius: 12,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xff1a3a2a),
          isExpanded: true,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white70,
          ),
          items: items
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    Color statusColor = product.status == AppConstants.productApproved
        ? Colors.green
        : product.status == AppConstants.productRejected
        ? Colors.red
        : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      product.imageBase64 != null &&
                          product.imageBase64!.isNotEmpty
                      ? Image.memory(
                          _imageService.base64ToImageBytes(
                            product.imageBase64!,
                          )!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(AppConstants.primaryColorValue),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${product.quantity} ${product.unit}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (product.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                product.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Listed: ${DateFormat('MMM d').format(product.createdAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editProduct(product),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteProduct(product),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    String selectedCategory = 'Vegetables';
    String selectedUnit = 'kg';
    Uint8List? selectedImageBytes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xff1a3a2a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Add New Product',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImagePicker(
                  selectedImageBytes,
                  (bytes) => setDialogState(() => selectedImageBytes = bytes),
                ),
                const SizedBox(height: 16),
                _buildDialogField(
                  nameController,
                  'Product Name',
                  'e.g. Red Tomatoes',
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  descriptionController,
                  'Description',
                  'Fresh from the farm...',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogField(
                        priceController,
                        'Price (₹)',
                        '0.00',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDialogField(
                        quantityController,
                        'Stock',
                        '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDialogDropdown(
                  value: selectedCategory,
                  label: 'Category',
                  items: ['Vegetables', 'Fruits', 'Grains', 'Dairy', 'Other'],
                  onChanged: (val) =>
                      setDialogState(() => selectedCategory = val!),
                ),
                const SizedBox(height: 12),
                _buildDialogDropdown(
                  value: selectedUnit,
                  label: 'Unit',
                  items: ['kg', 'piece', 'dozen', 'liter'],
                  onChanged: (val) => setDialogState(() => selectedUnit = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty &&
                    _farmerId != null) {
                  _processAddProduct(
                    nameController.text,
                    descriptionController.text,
                    priceController.text,
                    quantityController.text,
                    selectedCategory,
                    selectedUnit,
                    selectedImageBytes,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('LIST PRODUCT'),
            ),
          ],
        ),
      ),
    );
  }

  void _processAddProduct(
    String name,
    String desc,
    String price,
    String qty,
    String category,
    String unit,
    Uint8List? imageBytes,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      String? base64Image;
      if (imageBytes != null) {
        base64Image = await _imageService.convertImageToBase64(imageBytes);
      }

      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        farmerId: _farmerId!,
        farmerName: _farmerName ?? 'Unknown',
        farmerEmail: _farmerEmail ?? '',
        name: name,
        description: desc,
        price: double.parse(price),
        quantity: int.parse(qty),
        unit: unit,
        category: category,
        imageBase64: base64Image,
        status: AppConstants.productPending,
        createdAt: DateTime.now(),
      );

      final result = await _productService.addProduct(product);

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close dialog

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product listed! Waiting for approval.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editProduct(ProductModel product) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(
      text: product.description,
    );
    final priceController = TextEditingController(
      text: product.price.toString(),
    );
    final quantityController = TextEditingController(
      text: product.quantity.toString(),
    );
    String selectedCategory = product.category;
    String selectedUnit = product.unit;
    Uint8List? selectedImageBytes;
    String? currentImageBase64 = product.imageBase64;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xff1a3a2a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Edit Product',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImagePicker(
                  selectedImageBytes,
                  (bytes) => setDialogState(() => selectedImageBytes = bytes),
                  currentImageBase64: currentImageBase64,
                ),
                const SizedBox(height: 16),
                _buildDialogField(
                  nameController,
                  'Product Name',
                  'e.g. Red Tomatoes',
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  descriptionController,
                  'Description',
                  'Fresh from the farm...',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogField(
                        priceController,
                        'Price (₹)',
                        '0.00',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDialogField(
                        quantityController,
                        'Stock',
                        '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDialogDropdown(
                  value: selectedCategory,
                  label: 'Category',
                  items: ['Vegetables', 'Fruits', 'Grains', 'Dairy', 'Other'],
                  onChanged: (val) =>
                      setDialogState(() => selectedCategory = val!),
                ),
                const SizedBox(height: 12),
                _buildDialogDropdown(
                  value: selectedUnit,
                  label: 'Unit',
                  items: ['kg', 'piece', 'dozen', 'liter'],
                  onChanged: (val) => setDialogState(() => selectedUnit = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                  _processUpdateProduct(
                    product,
                    nameController.text,
                    descriptionController.text,
                    priceController.text,
                    quantityController.text,
                    selectedCategory,
                    selectedUnit,
                    selectedImageBytes,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('UPDATE PRODUCT'),
            ),
          ],
        ),
      ),
    );
  }

  void _processUpdateProduct(
    ProductModel oldProduct,
    String name,
    String desc,
    String price,
    String qty,
    String category,
    String unit,
    Uint8List? imageBytes,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      String? base64Image = oldProduct.imageBase64;
      if (imageBytes != null) {
        base64Image = await _imageService.convertImageToBase64(imageBytes);
      }

      final updatedProduct = ProductModel(
        id: oldProduct.id,
        farmerId: oldProduct.farmerId,
        farmerName: oldProduct.farmerName,
        farmerEmail: oldProduct.farmerEmail,
        name: name,
        description: desc,
        price: double.parse(price),
        quantity: int.parse(qty),
        unit: unit,
        category: category,
        imageBase64: base64Image,
        status: oldProduct.status,
        createdAt: oldProduct.createdAt,
      );

      final result = await _productService.updateProduct(updatedProduct);

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildImagePicker(
    Uint8List? selectedImageBytes,
    Function(Uint8List) onImageSelected, {
    String? currentImageBase64,
  }) {
    return GestureDetector(
      onTap: () async {
        ImageSource? source = kIsWeb
            ? ImageSource.gallery
            : await _showImageSourceOptions();
        if (source != null) {
          final bytes = await _imageService.pickImageBytes(source);
          if (bytes != null) onImageSelected(bytes);
        }
      },
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: selectedImageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(selectedImageBytes, fit: BoxFit.cover),
              )
            : (currentImageBase64 != null && currentImageBase64.isNotEmpty)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  _imageService.base64ToImageBytes(currentImageBase64)!,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 48,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add image',
                    style: GoogleFonts.inter(
                      color: Colors.white30,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<ImageSource?> _showImageSourceOptions() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xff1a3a2a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                ),
                title: Text(
                  'Camera',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                ),
                title: Text(
                  'Gallery',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDialogDropdown({
    required String value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xff1a3a2a),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      items: items
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _deleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1a3a2a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Delete Product',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
              try {
                final result = await _productService.deleteProduct(product.id);
                if (mounted) {
                  Navigator.pop(context);
                  if (result['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product deleted')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
