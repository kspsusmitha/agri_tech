import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';

class FarmerOrdersScreen extends StatelessWidget {
  const FarmerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Placeholder
        itemBuilder: (context, index) {
          return _buildOrderCard(
            context: context,
            orderId: 'ORD-${1000 + index}',
            buyerName: 'Buyer ${index + 1}',
            items: [
              {'name': 'Product ${index + 1}', 'quantity': 2, 'price': 50.0},
            ],
            totalAmount: 100.0 + (index * 50),
            status: _getStatus(index),
            date: DateTime.now().subtract(Duration(days: index)),
          );
        },
      ),
    );
  }

  String _getStatus(int index) {
    final statuses = [
      AppConstants.orderPending,
      AppConstants.orderApproved,
      AppConstants.orderProcessing,
      AppConstants.orderShipped,
      AppConstants.orderDelivered,
    ];
    return statuses[index % statuses.length];
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required String orderId,
    required String buyerName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String status,
    required DateTime date,
  }) {
    Color statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Buyer: $buyerName',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item['name']} x${item['quantity']}'),
                      Text('\$${item['price'].toStringAsFixed(2)}'),
                    ],
                  ),
                )),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d, y').format(date),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Total: \$${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.primaryColorValue),
                  ),
                ),
              ],
            ),
            if (status == AppConstants.orderPending ||
                status == AppConstants.orderApproved)
              Builder(
                builder: (builderContext) => Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(builderContext).showSnackBar(
                                SnackBar(content: Text('Order $orderId approved')),
                              );
                            },
                            child: const Text('Approve'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(builderContext).showSnackBar(
                                SnackBar(content: Text('Order $orderId rejected')),
                              );
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
                ),
              ),
            if (status == AppConstants.orderApproved)
              Builder(
                builder: (builderContext) => Column(
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(builderContext).showSnackBar(
                            SnackBar(content: Text('Order $orderId marked as processing')),
                          );
                        },
                        child: const Text('Start Processing'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.orderDelivered:
        return Colors.green;
      case AppConstants.orderShipped:
        return Colors.blue;
      case AppConstants.orderProcessing:
        return Colors.orange;
      case AppConstants.orderApproved:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

