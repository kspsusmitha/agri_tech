import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

class BillingService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Create a new transaction record
  Future<void> recordTransaction(TransactionModel transaction) async {
    try {
      await _database
          .child('transactions')
          .child(transaction.farmerId)
          .child(transaction.id)
          .set(transaction.toJson());
      debugPrint('✅ [Billing Service] Transaction recorded: ${transaction.id}');
    } catch (e) {
      debugPrint('❌ [Billing Service] Record transaction error: $e');
      rethrow;
    }
  }

  /// Stream transaction history for a farmer
  Stream<List<TransactionModel>> streamTransactions(String farmerId) {
    return _database.child('transactions').child(farmerId).onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final transactions = data.values
          .map((v) => TransactionModel.fromJson(Map<String, dynamic>.from(v)))
          .toList();
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return transactions;
    });
  }

  /// Get total revenue for a period
  Stream<double> streamTotalRevenue(String farmerId) {
    return streamTransactions(farmerId).map((transactions) {
      return transactions.fold(0.0, (sum, item) => sum + item.amount);
    });
  }

  /// Stream all transactions for admin oversight
  Stream<List<TransactionModel>> streamAllTransactions() {
    return _database.child('transactions').onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final Map<dynamic, dynamic> farmersData =
          event.snapshot.value as Map<dynamic, dynamic>;
      final List<TransactionModel> allTransactions = [];

      farmersData.forEach((farmerId, transactions) {
        if (transactions is Map) {
          transactions.forEach((id, transData) {
            allTransactions.add(
              TransactionModel.fromJson(Map<String, dynamic>.from(transData)),
            );
          });
        }
      });

      allTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allTransactions;
    });
  }

  // PDF/Excel export logic will be added here or in a separate utility service
}
