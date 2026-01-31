import 'package:flutter/material.dart';
import '../../services/inventory_service.dart';
import '../../models/inventory_model.dart';
import '../../services/session_service.dart';

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
    if (user == null)
      return const Scaffold(body: Center(child: Text('Please login')));

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      body: Column(
        children: [
          _buildSummaryCards(user.id),
          _buildCategorySelector(),
          Expanded(child: _buildInventoryList(user.id)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(user.id),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCards(String farmerId) {
    return StreamBuilder<List<InventoryModel>>(
      stream: _inventoryService.streamLowStockItems(farmerId),
      builder: (context, snapshot) {
        final lowStockCount = snapshot.data?.length ?? 0;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Low Stock',
                  lowStockCount.toString(),
                  Colors.red,
                  Icons.warning_amber_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Supplies',
                  'Active',
                  Colors.green,
                  Icons.category,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['All', 'Seeds', 'Fertilizers', 'Tools', 'Products'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: _selectedCategory == cat,
              onSelected: (val) => setState(() => _selectedCategory = cat),
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
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final items = _selectedCategory == 'All'
            ? snapshot.data!
            : snapshot.data!
                  .where((i) => i.category == _selectedCategory)
                  .toList();

        if (items.isEmpty) return const Center(child: Text('No items found'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isLow = item.quantity <= item.minThreshold;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  item.itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${item.category} • Updated: 1 day ago'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity} ${item.unit}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLow ? Colors.red : Colors.black,
                      ),
                    ),
                    if (isLow)
                      const Text(
                        'Low Stock',
                        style: TextStyle(color: Colors.red, fontSize: 10),
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

  void _showAddItemDialog(String farmerId) {
    // Basic dialog to add item
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    String category = 'Seeds';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Inventory Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: category,
              items: [
                'Seeds',
                'Fertilizers',
                'Tools',
                'Products',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => category = val!,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final item = InventoryModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                farmerId: farmerId,
                itemName: nameController.text,
                category: category,
                quantity: double.parse(quantityController.text),
                unit: 'kg', // Mock
                lastUpdated: DateTime.now(),
              );
              await _inventoryService.updateInventoryItem(item);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
