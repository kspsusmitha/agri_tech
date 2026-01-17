import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Placeholder
        itemBuilder: (context, index) {
          return _buildTransactionCard(
            orderId: 'ORD-${1000 + index}',
            buyerName: 'Buyer ${index + 1}',
            farmerName: 'Farmer ${index + 1}',
            amount: 250.0 + (index * 50),
            status: _getStatus(index),
            date: DateTime.now().subtract(Duration(days: index)),
          );
        },
      ),
    );
  }

  String _getStatus(int index) {
    final statuses = [
      AppConstants.orderDelivered,
      AppConstants.orderShipped,
      AppConstants.orderProcessing,
      AppConstants.orderApproved,
      AppConstants.orderPending,
    ];
    return statuses[index % statuses.length];
  }

  Widget _buildTransactionCard({
    required String orderId,
    required String buyerName,
    required String farmerName,
    required double amount,
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buyer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        buyerName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farmer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        farmerName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d, y').format(date),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.primaryColorValue),
                  ),
                ),
              ],
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

