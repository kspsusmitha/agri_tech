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
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?auto=format&fit=crop&q=80&w=1920', // Logistics/Packages
        gradient: AppConstants.oceanGradient,
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
                  color: Colors.white,
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
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
              ),
              Text(
                '#${order.id.substring(order.id.length - 8)}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  color: Colors.greenAccent,
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
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
              ),
              Text(
                DateFormat('MMM d, yyyy').format(order.createdAt),
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    // Determine current step index based on status
    int currentStep = 0;
    final status = order.status.toLowerCase();

    if (status == 'delivered') {
      currentStep = 3;
    } else if (status == 'shipped' || status == 'dispatched') {
      currentStep = 2;
    } else if (status == 'confirmed' || status == 'approved') {
      currentStep = 1;
    } else {
      currentStep = 0; // pending
    }

    if (status == 'cancelled') {
      return GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'This order was cancelled.',
            style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    }

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTimelineItem(
            title: 'Order Placed',
            subtitle: 'We have received your order.',
            time: DateFormat('hh:mm a').format(order.createdAt),
            isActive: currentStep >= 0,
            isLast: false,
          ),
          _buildTimelineItem(
            title: 'Confirmed',
            subtitle: 'Seller has confirmed your order.',
            time: currentStep >= 1 ? 'Approved' : 'Pending',
            isActive: currentStep >= 1,
            isLast: false,
          ),
          _buildTimelineItem(
            title: 'Shipped',
            subtitle: 'Your package is on the way.',
            time: currentStep >= 2 ? 'In Transit' : 'Pending',
            isActive: currentStep >= 2,
            isLast: false,
          ),
          _buildTimelineItem(
            title: 'Delivered',
            subtitle: 'Package delivered to your address.',
            time: currentStep >= 3 ? 'Delivered' : 'Pending',
            isActive: currentStep >= 3,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isActive,
    required bool isLast,
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
                color: isActive
                    ? Colors.greenAccent
                    : Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.green : Colors.transparent,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 14, color: Colors.black54)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isActive
                    ? Colors.greenAccent.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.2),
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
                      color: isActive ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      color: isActive ? Colors.greenAccent : Colors.white30,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
