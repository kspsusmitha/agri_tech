import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ProductApprovalScreen extends StatefulWidget {
  const ProductApprovalScreen({super.key});

  @override
  State<ProductApprovalScreen> createState() => _ProductApprovalScreenState();
}

class _ProductApprovalScreenState extends State<ProductApprovalScreen> {
  String _selectedFilter = 'Pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Approval'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5, // Placeholder
              itemBuilder: (context, index) {
                return _buildProductCard(
                  productName: 'Product ${index + 1}',
                  farmerName: 'Farmer ${index + 1}',
                  price: 100.0 + (index * 50),
                  quantity: 50 - (index * 5),
                  status: _selectedFilter.toLowerCase(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Pending', label: Text('Pending')),
                ButtonSegment(value: 'Approved', label: Text('Approved')),
                ButtonSegment(value: 'Rejected', label: Text('Rejected')),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedFilter = newSelection.first;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String productName,
    required String farmerName,
    required double price,
    required int quantity,
    required String status,
  }) {
    Color statusColor = status == AppConstants.productApproved
        ? Colors.green
        : status == AppConstants.productRejected
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By: $farmerName',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(AppConstants.primaryColorValue),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Qty: $quantity kg',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (status == AppConstants.productPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showApprovalDialog(context, productName, true);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showApprovalDialog(context, productName, false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Reject'),
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

  void _showApprovalDialog(
    BuildContext context,
    String productName,
    bool approve,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approve Product' : 'Reject Product'),
        content: Text(
          approve
              ? 'Are you sure you want to approve "$productName"?'
              : 'Are you sure you want to reject "$productName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    approve
                        ? 'Product approved successfully'
                        : 'Product rejected',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? Colors.green : Colors.red,
            ),
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
}

