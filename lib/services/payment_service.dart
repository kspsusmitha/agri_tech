import 'package:flutter/foundation.dart';

class PaymentService {
  /// Simulate a payment process
  /// Returns a map with success status and transaction ID
  Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String method,
    required Map<String, String> details,
  }) async {
    debugPrint(
      '🔵 [Payment Service] Processing payment of ₹$amount via $method',
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate occasional random failure (optional, for demo let's keep it mostly success)
    // if (amount > 10000) return {'success': false, 'message': 'Limit exceeded'};

    final transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
    debugPrint(
      '✅ [Payment Service] Payment successful. Transaction ID: $transactionId',
    );

    return {
      'success': true,
      'transactionId': transactionId,
      'message': 'Payment successful',
    };
  }
}
