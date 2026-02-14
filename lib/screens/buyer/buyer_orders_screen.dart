import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/order_service.dart';
import '../../services/medicine_order_service.dart';
import '../../services/session_service.dart';
import '../../models/order_model.dart';
import '../../models/medicine_order_model.dart';
import 'track_order_screen.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyerOrdersScreen extends StatefulWidget {
  final int initialIndex;
  const BuyerOrdersScreen({super.key, this.initialIndex = 0});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> {
  final OrderService _orderService = OrderService();
  final MedicineOrderService _medOrderService = MedicineOrderService();
  final String _buyerId = SessionService().user?.id ?? 'guest';

  @override
  Widget build(BuildContext context) {
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
              color: Colors.black, // Changed to black
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            indicatorColor: Colors.black, // Changed to black
            labelColor: Colors.black, // Changed to black
            unselectedLabelColor: Colors.black54, // Changed to black54
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Products'),
              Tab(text: 'Medicines'),
            ],
          ),
        ),
        body: ScreenBackground(
          imagePath:
              'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&q=80&w=1920', // Light farming/nature background
          gradient: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ], // Light gradient
          child: TabBarView(
            children: [_buildProductOrdersList(), _buildMedicineOrdersList()],
          ),
        ),
      ),
    );
  }

  Widget _buildProductOrdersList() {
    return StreamBuilder<List<OrderModel>>(
      stream: _orderService.streamBuyerOrders(_buyerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black26),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return _buildEmptyState(
            'No product orders',
            'Your fresh produce orders will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 90, 16, 16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(orders[index]);
          },
        );
      },
    );
  }

  Widget _buildMedicineOrdersList() {
    return StreamBuilder<List<MedicineOrderModel>>(
      stream: _medOrderService.streamFarmerOrders(_buyerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black26),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return _buildEmptyState(
            'No medicine orders',
            'Your medicine/supply orders will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 90, 16, 16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildMedicineOrderCard(orders[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_outlined, size: 64, color: Colors.black26),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(color: Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.black54,
          iconColor: Colors.black87,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            'Order #${order.id.split('-').last}',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            dateStr,
            style: GoogleFonts.inter(color: Colors.black54, fontSize: 13),
          ),
          trailing: _buildStatusChip(order.status),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 12),
                  Text(
                    'Items',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.productName} x ${item.quantity}',
                            style: GoogleFonts.inter(color: Colors.black87),
                          ),
                          Text(
                            '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TrackOrderScreen(order: order),
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_shipping_rounded, size: 18),
                      label: const Text('Track Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        side: const BorderSide(color: Colors.black12),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (order.status == 'delivered' && order.rating == null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _showReviewDialog(order),
                        icon: const Icon(
                          Icons.star_border,
                          color: Colors.amber,
                        ),
                        label: const Text(
                          'Leave a Review',
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                    )
                  else if (order.rating != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Review:',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order.rating ?? '',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          if (order.feedback != null &&
                              order.feedback!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                order.feedback!,
                                style: GoogleFonts.inter(
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
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
      ),
    );
  }

  Widget _buildMedicineOrderCard(MedicineOrderModel order) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  color: Colors.black87,
                ),
              ),
              _buildStatusChip(order.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Qty: ${order.quantity} • Total: ₹${order.totalAmount}',
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Date: $dateStr',
            style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'delivered':
        color = Colors.green[700]!;
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        color = Colors.red[700]!;
        icon = Icons.cancel_outlined;
        break;
      case 'shipped':
      case 'in transit':
      case 'dispatched':
        color = Colors.blue[700]!;
        icon = Icons.local_shipping_outlined;
        break;
      case 'approved':
        color = Colors.purple[700]!;
        icon = Icons.verified_outlined;
        break;
      case 'pending':
      default:
        color = Colors.orange[800]!;
        icon = Icons.pending_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(OrderModel order) {
    double ratingValue = 5;
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Rate your order',
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < ratingValue ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () =>
                        setDialogState(() => ratingValue = index + 1.0),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Share your feedback...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _orderService.submitReview(
                  order.id,
                  ratingValue,
                  feedbackController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your review!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('SUBMIT'),
            ),
          ],
        ),
      ),
    );
  }
}
