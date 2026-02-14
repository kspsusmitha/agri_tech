import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/inventory_service.dart';
import '../../models/inventory_model.dart';
import '../../services/session_service.dart';
import '../../widgets/glass_widgets.dart';
import '../../utils/constants.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _inventoryService = InventoryService();
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final user = SessionService().user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Inventory Management',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1595841696677-6489b3f7a8ee?auto=format&fit=crop&q=80&w=1920', // Warehouse/Storage background
        gradient: AppConstants.primaryGradient,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + 24),
            _buildSummaryCards(user.id),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            Expanded(child: _buildInventoryList(user.id)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(user.id),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add),
        label: Text(
          'Add Item',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(String farmerId) {
    return StreamBuilder<List<InventoryModel>>(
      stream: _inventoryService.streamLowStockItems(farmerId),
      builder: (context, snapshot) {
        final lowStockCount = snapshot.data?.length ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildStatGlassCard(
                  'Low Stock',
                  lowStockCount.toString(),
                  Colors.redAccent,
                  Icons.warning_amber_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatGlassCard(
                  'Supplies',
                  'Active',
                  Colors.greenAccent,
                  Icons.category_rounded,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatGlassCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['All', 'Seeds', 'Fertilizers', 'Tools', 'Products'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.white24,
                  ),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.black87 : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryList(String farmerId) {
    return StreamBuilder<List<InventoryModel>>(
      stream: _inventoryService.streamInventory(farmerId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final items = _selectedCategory == 'All'
            ? snapshot.data!
            : snapshot.data!
                  .where((i) => i.category == _selectedCategory)
                  .toList();

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.white24,
                ),
                const SizedBox(height: 16),
                Text(
                  'No items found',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add items to track your inventory',
                  style: GoogleFonts.inter(color: Colors.white60),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isLow = item.quantity <= item.minThreshold;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(item.category),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.category} • Alert at: ${item.minThreshold} ${item.unit}',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.quantity} ${item.unit}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isLow ? Colors.redAccent : Colors.white,
                          ),
                        ),
                        if (isLow)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              'Low Stock',
                              style: GoogleFonts.inter(
                                color: Colors.redAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white54,
                            size: 18,
                          ),
                          onPressed: () => _showEditItemDialog(item),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Seeds':
        return Icons.grass_rounded;
      case 'Fertilizers':
        return Icons.science_rounded;
      case 'Tools':
        return Icons.build_rounded;
      case 'Products':
        return Icons.eco_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  void _showAddItemDialog(String farmerId) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final thresholdController = TextEditingController(text: '10');
    String category = 'Seeds';
    String unit = 'kg';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xff1a0b2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Add Inventory Item',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Item Name', Icons.label),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        quantityController,
                        'Quantity',
                        Icons.production_quantity_limits,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: unit,
                        dropdownColor: const Color(0xff2d1f45),
                        style: GoogleFonts.inter(color: Colors.white),
                        items: ['kg', 'g', 'L', 'ml', 'pcs', 'bags']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => unit = val!),
                        decoration: _buildInputDecoration('Unit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: const Color(0xff2d1f45),
                  style: GoogleFonts.inter(color: Colors.white),
                  items: ['Seeds', 'Fertilizers', 'Tools', 'Products']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => category = val!),
                  decoration: _buildInputDecoration('Category'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  thresholdController,
                  'Low Stock Alert Limit',
                  Icons.notifications_active,
                  isNumber: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    quantityController.text.isEmpty)
                  return;

                final item = InventoryModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  farmerId: farmerId,
                  itemName: nameController.text,
                  category: category,
                  quantity: double.tryParse(quantityController.text) ?? 0,
                  unit: unit,
                  minThreshold: double.tryParse(thresholdController.text) ?? 10,
                  lastUpdated: DateTime.now(),
                );
                await _inventoryService.updateInventoryItem(item);
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(InventoryModel item) {
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final thresholdController = TextEditingController(
      text: item.minThreshold.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1a0b2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Update ${item.itemName}',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Stock: ${item.quantity} ${item.unit}',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              quantityController,
              'New Quantity',
              Icons.production_quantity_limits,
              isNumber: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              thresholdController,
              'Alert Limit',
              Icons.notifications_active,
              isNumber: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Delete functionality could be added here
              await _inventoryService.deleteInventoryItem(
                item.farmerId,
                item.id,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedItem = InventoryModel(
                id: item.id,
                farmerId: item.farmerId,
                itemName: item.itemName,
                category: item.category,
                quantity: double.tryParse(quantityController.text) ?? 0,
                unit: item.unit,
                minThreshold:
                    double.tryParse(thresholdController.text) ??
                    item.minThreshold,
                lastUpdated: DateTime.now(),
              );
              await _inventoryService.updateInventoryItem(updatedItem);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.greenAccent),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _buildInputDecoration(
        label,
      ).copyWith(prefixIcon: Icon(icon, color: Colors.white54)),
    );
  }
}
