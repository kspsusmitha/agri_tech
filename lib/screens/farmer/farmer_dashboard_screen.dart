import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/session_service.dart';
import '../role_selection_screen.dart';
import 'disease_detection_screen.dart';
import 'crop_management_screen.dart';
import 'product_listing_screen.dart';
import 'farmer_orders_screen.dart';
import 'weather_alert_screen.dart';
import 'inventory_screen.dart';
import '../community/community_home_screen.dart';
import 'farmer_medicine_orders_screen.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Farmer Hub',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
            onPressed: () {},
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
      ),
      body: Stack(
        children: [
          const GradientBackground(colors: AppConstants.primaryGradient),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Image Slider at Top
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ImageSlider(
                      imageUrls: [
                        'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?auto=format&fit=crop&q=80&w=800',
                        'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&q=80&w=800',
                        'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&q=80&w=800',
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Welcome Message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, Farmer 👋',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Everything you need is at your fingertips.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildGlassStatsRow(context),
                  ),
                  const SizedBox(height: 32),

                  // Quick Actions Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Tools & Services',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildQuickActionsGrid(context),
                  ),
                  const SizedBox(height: 32),

                  // Recent Crops with Glassmorphism
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildRecentCropsGlass(context),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildGlassStatCard(
            'Crops',
            '12',
            Icons.agriculture_rounded,
            AppConstants.primaryGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGlassStatCard(
            'Sales',
            '8',
            Icons.inventory_2_rounded,
            AppConstants.oceanGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGlassStatCard(
            'Orders',
            '15',
            Icons.shopping_bag_rounded,
            AppConstants.sunsetGradient,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassStatCard(
    String title,
    String value,
    IconData icon,
    List<Color> gradient,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
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
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
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
          'Disease AI',
          Icons.bug_report_rounded,
          AppConstants.sunsetGradient,
          () => _navigateTo(context, const DiseaseDetectionScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Crop Sync',
          Icons.sync_rounded,
          AppConstants.primaryGradient,
          () => _navigateTo(context, const CropManagementScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Marketplace',
          Icons.storefront_rounded,
          AppConstants.oceanGradient,
          () => _navigateTo(context, const ProductListingScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Product Orders',
          Icons.receipt_long_rounded,
          AppConstants.sunsetGradient,
          () => _navigateTo(context, const FarmerOrdersScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Med & Fert',
          Icons.medication_rounded,
          AppConstants.purpleGradient,
          () => _navigateTo(context, const FarmerMedicineOrdersScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Weather',
          Icons.wb_cloudy_rounded,
          AppConstants.oceanGradient,
          () => _navigateTo(context, const WeatherAlertScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Community',
          Icons.forum_rounded,
          AppConstants.purpleGradient,
          () => _navigateTo(context, const CommunityHomeScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Inventory',
          Icons.grid_view_rounded,
          AppConstants.primaryGradient,
          () => _navigateTo(context, const InventoryScreen()),
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

  Widget _buildRecentCropsGlass(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Crops',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () =>
                    _navigateTo(context, const CropManagementScreen()),
                child: Text(
                  'View Details',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCropItemGlass(
            'Tomato Hybrid',
            'Vegetative Phase',
            '45 Days',
            Icons.eco_rounded,
            Colors.redAccent,
          ),
          const Divider(color: Colors.white12),
          _buildCropItemGlass(
            'Sonora Wheat',
            'Flowering Phase',
            '62 Days',
            Icons.grass_rounded,
            Colors.amber,
          ),
          const Divider(color: Colors.white12),
          _buildCropItemGlass(
            'Sweet Corn',
            'Fruiting Phase',
            '78 Days',
            Icons.agriculture_rounded,
            Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildCropItemGlass(
    String name,
    String phase,
    String duration,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$phase • $duration',
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white24,
            size: 16,
          ),
        ],
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
            'Are you sure you want to end your session?',
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
