import 'package:flutter/material.dart';
import '../../models/medicine_order_model.dart';
import '../../services/medicine_order_service.dart';
import '../../services/session_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BusinessReportsScreen extends StatelessWidget {
  const BusinessReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerId = SessionService().user?.id ?? 'guest';
    final orderService = MedicineOrderService();

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(colors: AppConstants.primaryGradient),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: StreamBuilder<List<MedicineOrderModel>>(
                    stream: orderService.streamSellerOrders(sellerId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      final orders = snapshot.data ?? [];
                      // Calculate stats
                      final totalRevenue = orders.fold(
                        0.0,
                        (sum, order) => sum + order.totalAmount,
                      );
                      final totalOrders = orders.length;

                      // Process Data for Graph (Last 7 Days)
                      final Map<String, double> weeklyData = _getWeeklyData(
                        orders,
                      );

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Summary Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Total Revenue',
                                    '₹${totalRevenue.toStringAsFixed(0)}',
                                    Icons.currency_rupee_rounded,
                                    Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildSummaryCard(
                                    'Total Orders',
                                    '$totalOrders',
                                    Icons.shopping_bag_rounded,
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Weekly Sales Graph
                            GlassContainer(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Weekly Sales Performance',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Last 7 Days',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // Custom Bar Chart
                                  SizedBox(
                                    height: 200,
                                    child: _CustomBarChart(data: weeklyData),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Recent Transactions Header
                            Text(
                              'Recent Transactions',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Recent List
                            if (orders.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    'No transactions yet',
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...orders
                                  .take(5)
                                  .map((order) => _buildTransactionItem(order)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to aggregate data for the last 7 days
  Map<String, double> _getWeeklyData(List<MedicineOrderModel> orders) {
    Map<String, double> data = {};
    final now = DateTime.now();

    // Initialize last 7 days with 0
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = DateFormat('E').format(date); // Mon, Tue, etc.
      data[dayName] = 0.0;
    }

    // Fill with actual data
    for (var order in orders) {
      final orderDate = order.createdAt;
      final difference = now.difference(orderDate).inDays;
      if (difference < 7 && difference >= 0) {
        final dayName = DateFormat('E').format(orderDate);
        if (data.containsKey(dayName)) {
          data[dayName] = (data[dayName] ?? 0) + order.totalAmount;
        }
      }
    }
    return data;
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GlassContainer(
            borderRadius: 50,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Business Reports',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(MedicineOrderModel order) {
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
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.medicineName,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM, hh:mm a').format(order.createdAt),
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
                  '+₹${order.totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                    fontSize: 16,
                  ),
                ),
                Text(
                  order.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: _getStatusColor(order.status),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.greenAccent;
      case 'pending':
        return Colors.orangeAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }
}

class _CustomBarChart extends StatelessWidget {
  final Map<String, double> data;

  const _CustomBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.values.isEmpty
        ? 1.0
        : data.values.reduce((a, b) => a > b ? a : b);

    // Prevent division by zero
    final safeMax = maxValue == 0 ? 1.0 : maxValue;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.entries.map((entry) {
        final heightFactor = entry.value / safeMax;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bar
            Container(
              width: 16,
              height: 150 * heightFactor + 4, // Min height 4 for visibility
              decoration: BoxDecoration(
                color: entry.value > 0 ? Colors.white : Colors.white10,
                borderRadius: BorderRadius.circular(4),
                boxShadow: entry.value > 0
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              entry.key,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
