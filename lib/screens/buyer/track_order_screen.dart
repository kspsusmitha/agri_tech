import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../widgets/glass_widgets.dart';
import '../../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TrackOrderScreen extends StatelessWidget {
  final OrderModel order;

  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Track Order',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9), // More opaque for visibility
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?auto=format&fit=crop&q=80&w=1920', // Logistics/Packages
        gradient: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.7),
        ], // Light gradient for dark text
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfoCard(),
              const SizedBox(height: 32),
              Text(
                'Order Status',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildTimeline(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID',
                style: GoogleFonts.inter(color: Colors.black54, fontSize: 13),
              ),
              Text(
                '#${order.id.substring(order.id.length - 8)}',
                style: GoogleFonts.outfit(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.black12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount',
                style: GoogleFonts.inter(color: Colors.black54, fontSize: 13),
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date',
                style: GoogleFonts.inter(color: Colors.black54, fontSize: 13),
              ),
              Text(
                DateFormat('MMM d, yyyy').format(order.createdAt),
                style: GoogleFonts.inter(color: Colors.black87, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    int currentStep = 0;
    final status = order.status.toLowerCase();

    // Mapping status to steps
    if (status == 'delivered') {
      currentStep = 4;
    } else if (status == 'shipped' ||
        status == 'dispatched' ||
        status == 'in transit') {
      currentStep = 3;
    } else if (status == 'confirmed' || status == 'approved') {
      currentStep = 2;
    } else {
      currentStep = 1; // Order Placed
    }

    if (status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Center(
          child: Text(
            'This order was cancelled.',
            style: GoogleFonts.outfit(color: Colors.red[700], fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
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
      child: Column(
        children: [
          _buildTimelineItem(
            title: 'Order Placed',
            subtitle: 'We have received your order.',
            date: order.createdAt,
            isActive: currentStep >= 1,
            isLast: false,
          ),
          _buildTimelineItem(
            title: 'Confirmed',
            subtitle: 'Seller has confirmed your order.',
            date: order.createdAt.add(const Duration(minutes: 30)),
            isActive: currentStep >= 2,
            isLast: false,
            isEstimated: currentStep < 2,
          ),
          _buildTimelineItem(
            title: 'Shipped',
            subtitle: 'Your package is on the way.',
            date: order.createdAt.add(const Duration(hours: 4)),
            isActive: currentStep >= 3,
            isLast: false,
            isEstimated: currentStep < 3,
          ),
          _buildTimelineItem(
            title: 'Delivered',
            subtitle: 'Package delivered to your address.',
            date: order.createdAt.add(const Duration(days: 2)),
            isActive: currentStep >= 4,
            isLast: true,
            isEstimated: currentStep < 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required DateTime date,
    required bool isActive,
    required bool isLast,
    bool isEstimated = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? Colors.green[600] : Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.green[800]! : Colors.transparent,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isActive ? Colors.green[300] : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: isActive ? Colors.black87 : Colors.black45,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, hh:mm a').format(date),
                    style: GoogleFonts.inter(
                      color: isActive ? Colors.green[700] : Colors.black38,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (isEstimated)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Est.',
                        style: GoogleFonts.inter(
                          color: Colors.orange[800],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
