import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../services/medicine_service.dart';
import '../../models/medicine_model.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:async';

class ProductApprovalScreen extends StatefulWidget {
  const ProductApprovalScreen({super.key});

  @override
  State<ProductApprovalScreen> createState() => _ProductApprovalScreenState();
}

class _ProductApprovalScreenState extends State<ProductApprovalScreen> {
  final ProductService _productService = ProductService();
  final MedicineService _medicineService = MedicineService();
  String _selectedFilter = 'Pending';

  // Stream controller to emit combined lists
  late StreamController<List<dynamic>> _combinedStreamController;
  // Subscriptions to input streams
  StreamSubscription? _productSubscription;
  StreamSubscription? _medicineSubscription;
  // Local cache of latest data
  List<ProductModel> _products = [];
  List<MedicineModel> _medicines = [];

  @override
  void initState() {
    super.initState();
    _combinedStreamController = StreamController<List<dynamic>>.broadcast();
    _initStreams();
  }

  void _initStreams() {
    _productSubscription = _productService.streamAllProducts().listen((
      products,
    ) {
      _products = products;
      _emitCombined();
    });

    _medicineSubscription = _medicineService.streamAllMedicines().listen((
      medicines,
    ) {
      _medicines = medicines;
      _emitCombined();
    });
  }

  void _emitCombined() {
    final allItems = [..._products, ..._medicines];
    allItems.sort((a, b) {
      final dateA = a is ProductModel
          ? a.createdAt
          : (a as MedicineModel).createdAt;
      final dateB = b is ProductModel
          ? b.createdAt
          : (b as MedicineModel).createdAt;
      return dateB.compareTo(dateA);
    });
    _combinedStreamController.add(allItems);
  }

  @override
  void dispose() {
    _productSubscription?.cancel();
    _medicineSubscription?.cancel();
    _combinedStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Product & Medicine Decisions',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1615937651199-6310bfdaf81e?auto=format&fit=crop&q=80&w=1920', // Warehouse/Product
        gradient: AppConstants.purpleGradient,
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 40),
            _buildFilterBar(),
            Expanded(
              child: StreamBuilder<List<dynamic>>(
                stream: _combinedStreamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !_combinedStreamController.hasListener) {
                    // Only show loader if we haven't emitted yet.
                    // Note: StreamBuilder might show waiting initially.
                    // Given we start listening in initState, we might have data quickly.
                    // But standard waiting check is fine.
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white24),
                    );
                  }

                  if (!snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white24),
                    );
                  }

                  final allItems = snapshot.data ?? [];
                  final filteredItems = allItems.where((item) {
                    final status = item is ProductModel
                        ? item.status
                        : (item as MedicineModel).status;
                    return status.toLowerCase() ==
                        _selectedFilter.toLowerCase();
                  }).toList();

                  if (filteredItems.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildItemCard(item);
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_rounded,
            size: 80,
            color: Colors.white10,
          ),
          const SizedBox(height: 20),
          Text(
            'No $_selectedFilter items',
            style: GoogleFonts.inter(color: Colors.white30, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(4),
        borderRadius: 16,
        child: Row(
          children: [
            _buildFilterTab('Pending'),
            _buildFilterTab('Approved'),
            _buildFilterTab('Rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    bool isSelected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : Colors.white38,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    final isProduct = item is ProductModel;
    final name = isProduct ? item.name : (item as MedicineModel).name;
    final status = isProduct ? item.status : (item as MedicineModel).status;
    final price = isProduct ? item.price : (item as MedicineModel).price;
    final imageBase64 = isProduct
        ? item.imageBase64
        : (item as MedicineModel).imageUrl;
    final subtitle = isProduct
        ? item.farmerName
        : (item as MedicineModel).category;
    final unitOrType = isProduct ? item.unit : 'unit';

    Color statusColor = status == AppConstants.productApproved
        ? Colors.greenAccent
        : status == AppConstants.productRejected
        ? Colors.redAccent
        : Colors.orangeAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Item Image
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: imageBase64 != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child:
                              imageBase64.startsWith('data:image') ||
                                  imageBase64.length > 100
                              ? Image.memory(
                                  base64Decode(imageBase64.split(',').last),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  imageBase64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_rounded,
                                        color: Colors.white10,
                                      ),
                                ),
                        )
                      : const Icon(Icons.image_rounded, color: Colors.white10),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isProduct
                                ? Icons.person_pin_rounded
                                : Icons.medical_services_rounded,
                            size: 14,
                            color: Colors.white38,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              subtitle,
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹$price',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (isProduct)
                            Text(
                              ' / $unitOrType',
                              style: GoogleFonts.inter(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (isProduct)
                  Text(
                    'Stock: ${(item as ProductModel).quantity} ${item.unit}',
                    style: GoogleFonts.inter(
                      color: Colors.white24,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            if (status == AppConstants.productPending) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showApprovalDialog(context, item, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.withOpacity(0.8),
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'APPROVE',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _showApprovalDialog(context, item, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'REJECT',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, dynamic item, bool approve) {
    final isProduct = item is ProductModel;
    final name = isProduct ? item.name : (item as MedicineModel).name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1a0b2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          approve ? 'Approve Item' : 'Reject Item',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          approve
              ? 'Are you sure you want to approve "$name"?'
              : 'Are you sure you want to reject "$name"?',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newStatus = approve
                  ? AppConstants.productApproved
                  : AppConstants.productRejected;

              if (isProduct) {
                _productService.updateProductStatus(item.id, newStatus);
              } else {
                _medicineService.updateMedicineStatus(
                  (item as MedicineModel).id,
                  newStatus,
                );
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    approve ? 'Item approved successfully' : 'Item rejected',
                  ),
                  backgroundColor: approve ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? Colors.greenAccent : Colors.redAccent,
              foregroundColor: approve ? Colors.black87 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(approve ? 'APPROVE' : 'REJECT'),
          ),
        ],
      ),
    );
  }
}
