import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

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
            items: [
              {'name': 'Product ${index + 1}', 'quantity': 2, 'price': 50.0},
              {'name': 'Product ${index + 2}', 'quantity': 1, 'price': 30.0},
            ],
            totalAmount: 100.0 + (index * 50),
            status: _getStatus(index),
            date: DateTime.now().subtract(Duration(days: index)),
            farmerName: 'Farmer ${index + 1}',
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
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String status,
    required DateTime date,
    required String farmerName,
  }) {
    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          orderId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat('MMM d, y • h:mm a').format(date),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farmer: $farmerName',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Items',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
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
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\$${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(AppConstants.primaryColorValue),
                      ),
                    ),
                  ],
                ),
                if (status == AppConstants.orderShipped ||
                    status == AppConstants.orderDelivered) ...[
                  const SizedBox(height: 16),
                  _buildTrackingInfo(status),
                ],
                if (status == AppConstants.orderDelivered)
                  Builder(
                    builder: (builderContext) => Column(
                      children: [
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(builderContext).showSnackBar(
                                const SnackBar(content: Text('Review submitted')),
                              );
                            },
                            icon: const Icon(Icons.rate_review),
                            label: const Text('Rate & Review'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfo(String status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Tracking Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTrackingStep('Order Placed', true),
          _buildTrackingStep('Order Confirmed', true),
          _buildTrackingStep('Processing', status != AppConstants.orderPending),
          _buildTrackingStep(
            'Shipped',
            status == AppConstants.orderShipped ||
                status == AppConstants.orderDelivered,
          ),
          _buildTrackingStep(
            'Delivered',
            status == AppConstants.orderDelivered,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(String step, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            step,
            style: TextStyle(
              color: completed ? Colors.black : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.orderDelivered:
        return Icons.check_circle;
      case AppConstants.orderShipped:
        return Icons.local_shipping;
      case AppConstants.orderProcessing:
        return Icons.sync;
      case AppConstants.orderApproved:
        return Icons.verified;
      default:
        return Icons.pending;
    }
  }
}

