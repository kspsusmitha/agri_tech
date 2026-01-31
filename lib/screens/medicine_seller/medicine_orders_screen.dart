import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/medicine_order_model.dart';
import '../../services/medicine_order_service.dart';
import '../../services/session_service.dart';

class MedicineOrdersScreen extends StatelessWidget {
  const MedicineOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerId = SessionService().user?.id ?? 'guest';
    final orderService = MedicineOrderService();

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Orders')),
      body: StreamBuilder<List<MedicineOrderModel>>(
        stream: orderService.streamSellerOrders(sellerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders received yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, orderService, order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    MedicineOrderService service,
    MedicineOrderModel order,
  ) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          order.medicineName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Status: ${order.status.toUpperCase()}'),
        trailing: Text(
          '₹${order.totalAmount}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Farmer:', order.farmerName),
                _buildInfoRow('Phone:', order.phone),
                _buildInfoRow('Address:', order.address),
                _buildInfoRow('Quantity:', '${order.quantity}'),
                _buildInfoRow('Date:', dateStr),
                const Divider(),
                const Text(
                  'Update Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (order.status == 'pending')
                      ElevatedButton(
                        onPressed: () =>
                            service.updateOrderStatus(order.id, 'approved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Approve'),
                      ),
                    if (order.status == 'approved')
                      ElevatedButton(
                        onPressed: () =>
                            service.updateOrderStatus(order.id, 'dispatched'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Dispatch'),
                      ),
                    if (order.status == 'dispatched')
                      ElevatedButton(
                        onPressed: () =>
                            service.updateOrderStatus(order.id, 'delivered'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Deliver'),
                      ),
                    if (order.status != 'cancelled' &&
                        order.status != 'delivered')
                      TextButton(
                        onPressed: () =>
                            service.updateOrderStatus(order.id, 'cancelled'),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
