import 'package:flutter/material.dart';
import '../../services/medicine_service.dart';
import '../../models/medicine_model.dart';
import '../../models/medicine_order_model.dart';
import '../../services/medicine_order_service.dart';
import '../../services/session_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_widgets.dart';
import 'farmer_medicine_orders_screen.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class MedicineSellerSearchScreen extends StatefulWidget {
  const MedicineSellerSearchScreen({super.key});

  @override
  State<MedicineSellerSearchScreen> createState() =>
      _MedicineSellerSearchScreenState();
}

class _MedicineSellerSearchScreenState
    extends State<MedicineSellerSearchScreen> {
  final MedicineService _medicineService = MedicineService();
  final MedicineOrderService _orderService = MedicineOrderService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Supplies & Medicines',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FarmerMedicineOrdersScreen(),
              ),
            ),
            tooltip: 'Order History',
          ),
        ],
      ),
      body: GradientBackground(
        colors: AppConstants.deepBlueGradient,
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 40),
            _buildSearchBar(),
            Expanded(child: _buildMedicineList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 16,
        child: TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Target disease or medicine name...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineList() {
    return StreamBuilder<List<MedicineModel>>(
      stream: _medicineService.streamAllMedicines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white24),
          );
        }

        var medicines = snapshot.data ?? [];
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          medicines = medicines
              .where(
                (m) =>
                    m.name.toLowerCase().contains(query) ||
                    m.targetDisease.toLowerCase().contains(query),
              )
              .toList();
        }

        if (medicines.isEmpty) {
          return Center(
            child: GlassContainer(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No supplies found matching your search.',
                    style: GoogleFonts.inter(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            final med = medicines[index];
            return _buildMedicineCard(med);
          },
        );
      },
    );
  }

  Widget _buildMedicineCard(MedicineModel med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        child: Row(
          children: [
            Hero(
              tag: 'med_${med.id}',
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: med.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          base64Decode(med.imageUrl!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.medication_rounded,
                        color: Colors.white10,
                        size: 40,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'For: ${med.targetDisease}',
                      style: GoogleFonts.inter(
                        color: Colors.blueAccent[100],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_rounded,
                        size: 14,
                        color: Colors.white38,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          med.providerName,
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${med.price}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _showOrderDialog(med),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'BUY',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDialog(MedicineModel medicine) {
    int quantity = 1;
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xff0d1b2a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Order ${medicine.name}',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantity',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_rounded,
                              color: Colors.white,
                            ),
                            onPressed: quantity > 1
                                ? () => setDialogState(() => quantity--)
                                : null,
                          ),
                          Text(
                            '$quantity',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () => setDialogState(() => quantity++),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDialogField(
                  addressController,
                  'Delivery Address',
                  'Full address...',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  phoneController,
                  'Phone Number',
                  '10-digit number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.inter(color: Colors.white38),
                    ),
                    Text(
                      '₹${medicine.price * quantity}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                if (addressController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  _processOrder(
                    medicine,
                    quantity,
                    addressController.text,
                    phoneController.text,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all details')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('CONFIRM ORDER'),
            ),
          ],
        ),
      ),
    );
  }

  void _processOrder(
    MedicineModel medicine,
    int quantity,
    String address,
    String phone,
  ) async {
    final order = MedicineOrderModel(
      id: 'MORD-${DateTime.now().millisecondsSinceEpoch}',
      medicineId: medicine.id,
      medicineName: medicine.name,
      farmerId: SessionService().user?.id ?? 'guest',
      farmerName: SessionService().user?.name ?? 'Farmer',
      sellerId: medicine.sellerId,
      price: medicine.price,
      quantity: quantity,
      totalAmount: medicine.price * quantity,
      status: 'pending',
      createdAt: DateTime.now(),
      address: address,
      phone: phone,
    );

    await _orderService.placeOrder(order);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
}
