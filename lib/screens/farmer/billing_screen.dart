import 'package:flutter/material.dart';
import '../../services/billing_service.dart';
import '../../models/transaction_model.dart';
import '../../services/session_service.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BillingService billingService = BillingService();
    final user = SessionService().user;
    if (user == null)
      return const Scaffold(body: Center(child: Text('Please login')));

    return Scaffold(
      appBar: AppBar(title: const Text('Billing & Records')),
      body: Column(
        children: [
          _buildRevenueHeader(billingService, user.id),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Export',
                  style: TextStyle(
                    color: Color(AppConstants.primaryColorValue),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildTransactionList(billingService, user.id)),
        ],
      ),
    );
  }

  Widget _buildRevenueHeader(BillingService service, String farmerId) {
    return StreamBuilder<double>(
      stream: service.streamTotalRevenue(farmerId),
      builder: (context, snapshot) {
        final revenue = snapshot.data ?? 0.0;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(AppConstants.primaryColorValue),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Total Revenue',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${revenue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTrend('Weekly', '+12%'),
                  const SizedBox(width: 24),
                  _buildTrend('Monthly', '+5%'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrend(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTransactionList(BillingService service, String farmerId) {
    return StreamBuilder<List<TransactionModel>>(
      stream: service.streamTransactions(farmerId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty)
          return const Center(child: Text('No transactions found'));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final tx = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.blue,
                  ),
                ),
                title: Text(
                  tx.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(DateFormat('MMM d, yyyy').format(tx.timestamp)),
                trailing: Text(
                  '₹${tx.amount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
