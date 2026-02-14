import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../models/medicine_order_model.dart';
import '../../services/order_service.dart';
import '../../services/medicine_order_service.dart';
import '../../services/session_service.dart';

class FarmerOrdersScreen extends StatefulWidget {
  final int initialIndex;
  const FarmerOrdersScreen({super.key, this.initialIndex = 0});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  final OrderService _orderService = OrderService();
  final MedicineOrderService _medOrderService = MedicineOrderService();
  final SessionService _sessionService = SessionService();
  String? _farmerId;
  String? _farmerName; // To check if user is logged in

  @override
  void initState() {
    super.initState();
    final user = _sessionService.user;
    _farmerId = user?.id;
    _farmerName = user?.name;
  }

  @override
  Widget build(BuildContext context) {
    if (_farmerId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: User not logged in')),
      );
    }

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialIndex,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'My Orders',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Received (Sales)'),
              Tab(text: 'Placed (Purchases)'),
            ],
          ),
        ),
        body: ScreenBackground(
          imagePath:
              'https://images.unsplash.com/photo-1595855708573-455bc328227b?auto=format&fit=crop&q=80&w=1920', // Crates of food
          gradient: AppConstants.oceanGradient,
          child: TabBarView(
            children: [_buildReceivedOrdersList(), _buildPlacedOrdersList()],
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedOrdersList() {
    return StreamBuilder<List<OrderModel>>(
      stream: _orderService.streamFarmerSales(_farmerId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading orders',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return _buildEmptyState(
            'No sales yet',
            'Your received orders will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            16,
            kToolbarHeight + 90, // Adjusted for TabBar
            16,
            16,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildSalesOrderCard(context, orders[index]);
          },
        );
      },
    );
  }

  Widget _buildPlacedOrdersList() {
    return StreamBuilder<List<MedicineOrderModel>>(
      stream: _medOrderService.streamFarmerOrders(_farmerId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading orders',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return _buildEmptyState(
            'No purchases yet',
            'Your medicine orders will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            16,
            kToolbarHeight + 90, // Adjusted for TabBar
            16,
            16,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildPurchaseOrderCard(orders[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: GoogleFonts.inter(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // --- Methods for Sales Orders (Received) ---

  Widget _buildSalesOrderCard(BuildContext context, OrderModel order) {
    Color statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: GoogleFonts.inter(
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
              'Customer ID: ${order.buyerId.substring(0, 5)}...',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.productName} x${item.quantity}',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d, y').format(order.createdAt),
                  style: GoogleFonts.inter(color: Colors.white60),
                ),
                Text(
                  'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            if (order.status == AppConstants.orderPending)
              Builder(
                builder: (builderContext) => Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateSalesStatus(
                              context,
                              order.id,
                              AppConstants.orderApproved,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                            ),
                            child: const Text('Approve'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateSalesStatus(
                              context,
                              order.id,
                              AppConstants.orderCancelled,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            if (order.status == AppConstants.orderApproved)
              Builder(
                builder: (builderContext) => Column(
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _updateSalesStatus(
                          context,
                          order.id,
                          AppConstants.orderProcessing,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Start Processing'),
                      ),
                    ),
                  ],
                ),
              ),

            if (order.status == AppConstants.orderProcessing)
              Builder(
                builder: (builderContext) => Column(
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _updateSalesStatus(
                          context,
                          order.id,
                          AppConstants.orderShipped,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Mark as Shipped'),
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

  Future<void> _updateSalesStatus(
    BuildContext context,
    String orderId,
    String status,
  ) async {
    try {
      await _orderService.updateOrderStatus(orderId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $status'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      case AppConstants.orderCancelled:
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // --- Methods for Purchase Orders (Placed) ---

  Widget _buildPurchaseOrderCard(MedicineOrderModel order) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.medicineName,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                _buildPurchaseStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Qty: ${order.quantity} • Total: ₹${order.totalAmount}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: $dateStr',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
        color = Colors.green;
        break;
      case 'dispatched':
        color = Colors.blue;
        break;
      case 'approved':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
    );
  }
}
