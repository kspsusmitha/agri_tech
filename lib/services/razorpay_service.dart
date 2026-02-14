import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';

class RazorpayService {
  late Razorpay _razorpay;
  Function(Map<String, dynamic>)? _onSuccess;
  Function(Map<String, dynamic>)? _onFailure;

  void init({
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Map<String, dynamic>) onFailure,
  }) {
    _razorpay = Razorpay();
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  void openCheckout({
    required double amount,
    required String name,
    required String description,
    required String contact,
    required String email,
  }) {
    var options = {
      // TODO: Replace with your actual Razorpay Key ID
      'key': 'rzp_test_PLACEHOLDER',
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Farm Tech',
      'description': description,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      _onFailure?.call({'message': e.toString()});
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    _onSuccess?.call({
      'success': true,
      'paymentId': response.paymentId,
      'orderId': response.orderId,
      'signature': response.signature,
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    _onFailure?.call({
      'success': false,
      'code': response.code,
      'message': response.message,
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    _onSuccess?.call({
      'success': true,
      'paymentId': 'WALLET_${response.walletName}',
      'message': 'External Wallet Selected',
    });
  }
}
