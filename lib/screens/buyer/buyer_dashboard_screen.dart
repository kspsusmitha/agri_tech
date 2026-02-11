import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/session_service.dart';
import '../../services/cart_service.dart';
import '../role_selection_screen.dart';
import 'product_browse_screen.dart';
import 'buyer_cart_screen.dart';
import 'buyer_orders_screen.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  final CartService _cartService = CartService();
  final String _buyerId = SessionService().user?.id ?? 'guest';

  int _selectedIndex = 0;

  final List<Color> _bgColors_0 = AppConstants.sunsetGradient;
  final List<Color> _bgColors_1 = AppConstants.primaryGradient;
  final List<Color> _bgColors_2 = AppConstants.oceanGradient;

  List<Color> get _currentGradient {
    switch (_selectedIndex) {
      case 1:
        return _bgColors_1;
      case 2:
        return _bgColors_2;
      default:
        return _bgColors_0;
    }
  }

  String get _currentImage {
    switch (_selectedIndex) {
      case 1:
        return 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&q=80&w=1920';
      case 2:
        return 'https://images.unsplash.com/photo-1549419134-2e259e218228?auto=format&fit=crop&q=80&w=1920';
      default:
        return 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=1920';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      // Only show Main AppBar on Home tab (Index 0) to avoid double AppBars
      appBar: _selectedIndex == 0 ? _buildHomeAppBar() : null,
      body: ScreenBackground(
        imagePath: _currentImage,
        gradient: _currentGradient,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(),
            const ProductBrowseScreen(), // Ensure this screen handles its own safe area/appbar if needed
            const BuyerOrdersScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildGlassBottomNav(context),
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      title: Text(
        'Buyer Hub',
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _cartService.streamCartItems(_buyerId),
          builder: (context, snapshot) {
            final cartItemCount = snapshot.data?.length ?? 0;
            return IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart_rounded, color: Colors.white),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => _navigateTo(context, const BuyerCartScreen()),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          onSelected: (value) {
            if (value == 'logout') _showLogoutDialog(context);
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: kToolbarHeight + 40,
      ), // Offset for transparent AppBar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ImageSlider(
              imageUrls: [
                'https://images.unsplash.com/photo-1560806887-1e4cd0b6bcd6?auto=format&fit=crop&q=80&w=800', // Fresh Red Apples
                'https://images.unsplash.com/photo-1547514701-42782101795e?auto=format&fit=crop&q=80&w=800', // Juicy Oranges
                'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&q=80&w=800', // Ripe Strawberries
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Healthy Choice ✨',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Farm-fresh produce delivered to you.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildQuickActions(context),
          ),
          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Featured Categories',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeaturedProducts(context),
          const SizedBox(height: 100), // Bottom padding for nav bar
        ],
      ),
    );
  }

  Widget _buildGlassBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: GlassContainer(
        borderRadius: 30,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_rounded),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_rounded),
              label: 'Orders',
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildActionGlassCard(
          context,
          'Explore Shop',
          Icons.shopping_basket_rounded,
          AppConstants.primaryGradient,
          () => setState(() => _selectedIndex = 1), // Switch to Shop Tab
        ),
        _buildActionGlassCard(
          context,
          'My Cart',
          Icons.shopping_cart_rounded,
          AppConstants.oceanGradient,
          () => _navigateTo(context, const BuyerCartScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Order History',
          Icons.history_rounded,
          AppConstants.sunsetGradient,
          () => setState(() => _selectedIndex = 2), // Switch to Orders Tab
        ),
        _buildActionGlassCard(
          context,
          'Track Delivery',
          Icons.local_shipping_rounded,
          AppConstants.purpleGradient,
          () => setState(() => _selectedIndex = 2), // Switch to Orders Tab
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildActionGlassCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return GlassContainer(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 40),
            const SizedBox(height: 16),
            Text(
              'Discover Premium Produce',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click "Explore Shop" to view all available organic products from our local farmers.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => _selectedIndex = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Visit Shop'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Logout', style: GoogleFonts.outfit(color: Colors.white)),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                SessionService().clearUser();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
