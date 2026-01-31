import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../services/billing_service.dart';
import '../../models/transaction_model.dart';
import '../../services/medicine_order_service.dart';
import '../../models/medicine_order_model.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BillingService billingService = BillingService();
    final MedicineOrderService medOrderService = MedicineOrderService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const GradientBackground(colors: AppConstants.purpleGradient),
          SafeArea(
            child: StreamBuilder<List<dynamic>>(
              stream: billingService.streamAllTransactions().map(
                (list) => list as List<dynamic>,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                return StreamBuilder<List<MedicineOrderModel>>(
                  stream: medOrderService.streamAllOrders(),
                  builder: (context, medSnapshot) {
                    final transactions = snapshot.data ?? [];
                    final medOrders = medSnapshot.data ?? [];

                    final combined = [...transactions, ...medOrders];
                    combined.sort((a, b) {
                      final dateA = a is TransactionModel
                          ? a.timestamp
                          : (a as MedicineOrderModel).createdAt;
                      final dateB = b is TransactionModel
                          ? b.timestamp
                          : (b as MedicineOrderModel).createdAt;
                      return dateB.compareTo(dateA);
                    });

                    if (combined.isEmpty) {
                      return Center(
                        child: Text(
                          'No transactions found.',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: combined.length,
                      itemBuilder: (context, index) {
                        final item = combined[index];
                        if (item is TransactionModel) {
                          return _buildTransactionCard(
                            orderId: item.id,
                            buyerName: item.buyerName,
                            farmerName: item.farmerName,
                            amount: item.amount,
                            status: item.status,
                            date: item.timestamp,
                            type: 'Product',
                          );
                        } else {
                          final order = item as MedicineOrderModel;
                          return _buildTransactionCard(
                            orderId: order.id,
                            buyerName: order.farmerName,
                            farmerName: order.sellerId,
                            amount: order.totalAmount,
                            status: order.status,
                            date: order.createdAt,
                            type: 'Medicine',
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard({
    required String orderId,
    required String buyerName,
    required String farmerName,
    required double amount,
    required String status,
    required DateTime date,
    required String type,
  }) {
    Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        borderRadius: 24,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${orderId.substring(orderId.length - 8).toUpperCase()}',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$type | ${status.toUpperCase()}',
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BUYER',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white38,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          buyerName,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.white12,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PARTNER',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white38,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          farmerName,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.white12, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, y • HH:mm').format(date),
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.orderDelivered:
        return Colors.greenAccent;
      case AppConstants.orderShipped:
        return Colors.blueAccent;
      case AppConstants.orderProcessing:
        return Colors.orangeAccent;
      case AppConstants.orderApproved:
        return Colors.purpleAccent;
      default:
        return Colors.white70;
    }
  }
}
