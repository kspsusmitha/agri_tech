import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/cart_service.dart';
import '../../services/session_service.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../services/payment_service.dart';
import 'dart:convert';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyerCartScreen extends StatefulWidget {
  const BuyerCartScreen({super.key});

  @override
  State<BuyerCartScreen> createState() => _BuyerCartScreenState();
}

class _BuyerCartScreenState extends State<BuyerCartScreen> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();
  final String _buyerId = SessionService().user?.id ?? 'guest';

  double _calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
            'https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&q=80&w=1920', // Shopping/Market
        gradient: AppConstants.oceanGradient,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _cartService.streamCartItems(_buyerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final cartItems = snapshot.data ?? [];

            if (cartItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      kToolbarHeight + 40,
                      16,
                      16,
                    ),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItem(cartItems[index]);
                    },
                  ),
                ),
                _buildCheckoutSection(cartItems),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
              ),
              child: item['imageBase64'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        base64Decode(item['imageBase64']),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image, color: Colors.white24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${item['farmerName']}',
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item['price'].toStringAsFixed(2)} / ${item['unit']}',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildQtyBtn(Icons.remove, () {
                              _cartService.updateQuantity(
                                _buyerId,
                                item['id'],
                                item['quantity'] - 1,
                              );
                            }),
                            Text(
                              '${item['quantity']}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            _buildQtyBtn(Icons.add, () {
                              _cartService.updateQuantity(
                                _buyerId,
                                item['id'],
                                item['quantity'] + 1,
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              onPressed: () {
                _cartService.removeFromCart(_buyerId, item['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['name']} removed from cart'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70, size: 16),
      onPressed: onTap,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildCheckoutSection(List<Map<String, dynamic>> items) {
    final total = _calculateTotal(items);
    return GlassContainer(
      borderRadius: 0, // Bottom sheet style
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCheckoutDialog(items, total),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGradient[0],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppConstants.primaryGradient[0].withOpacity(0.5),
                ),
                child: Text(
                  'PROCEED TO CHECKOUT',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(List<Map<String, dynamic>> items, double total) {
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    ValueNotifier<bool> isProcessing = ValueNotifier(false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ValueListenableBuilder<bool>(
        valueListenable: isProcessing,
        builder: (context, processing, child) {
          return AlertDialog(
            backgroundColor: const Color(0xff1a0b2e),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              'Checkout',
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (processing) ...[
                    const CircularProgressIndicator(color: Colors.purpleAccent),
                    const SizedBox(height: 16),
                    Text(
                      'Processing Payment...',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                  ] else ...[
                    _buildDialogField(
                      addressController,
                      'Delivery Address',
                      Icons.location_on_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildDialogField(
                      phoneController,
                      'Phone Number',
                      Icons.phone_rounded,
                      isPhone: true,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Payable:',
                            style: GoogleFonts.inter(color: Colors.white60),
                          ),
                          Text(
                            '₹${total.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: processing
                ? []
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (addressController.text.isNotEmpty &&
                            phoneController.text.isNotEmpty) {
                          isProcessing.value = true;

                          final paymentResult = await _paymentService
                              .processPayment(
                                amount: total,
                                method: 'Demo Card',
                                details: {},
                              );

                          if (paymentResult['success'] == true) {
                            final orderId =
                                'ORD-${DateTime.now().millisecondsSinceEpoch}';
                            final order = OrderModel(
                              id: orderId,
                              buyerId: _buyerId,
                              farmerId: items.first['farmerId'],
                              items: items
                                  .map(
                                    (i) => OrderItem(
                                      productId: i['id'],
                                      productName: i['name'],
                                      quantity: i['quantity'],
                                      price: i['price'].toDouble(),
                                    ),
                                  )
                                  .toList(),
                              totalAmount: total,
                              shippingAddress: addressController.text,
                              createdAt: DateTime.now(),
                            );

                            await _orderService.placeOrder(order);
                            await _cartService.clearCart(_buyerId);

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Payment Successful! Order placed.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context); // Return to dashboard
                            }
                          } else {
                            isProcessing.value = false;
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Payment Failed: ${paymentResult['message']}',
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all details'),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('PAY & PLACE ORDER'),
                    ),
                  ],
          );
        },
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool isPhone = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purpleAccent),
        ),
      ),
    );
  }
}
