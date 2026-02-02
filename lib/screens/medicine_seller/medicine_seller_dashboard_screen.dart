import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../../services/medicine_service.dart';
import '../../models/medicine_model.dart';
import '../role_selection_screen.dart';
import 'add_medicine_screen.dart';
import 'medicine_inventory_screen.dart';
import 'medicine_orders_screen.dart';
import 'business_reports_screen.dart';
import '../../widgets/glass_widgets.dart';
import '../../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicineSellerDashboardScreen extends StatefulWidget {
  const MedicineSellerDashboardScreen({super.key});

  @override
  State<MedicineSellerDashboardScreen> createState() =>
      _MedicineSellerDashboardScreenState();
}

class _MedicineSellerDashboardScreenState
    extends State<MedicineSellerDashboardScreen> {
  final MedicineService _medicineService = MedicineService();
  final String _sellerId = SessionService().user?.id ?? 'guest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Seller Hub',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
      body: StreamBuilder<List<MedicineModel>>(
        stream: _medicineService.streamSellerMedicines(_sellerId),
        builder: (context, snapshot) {
          final medicines = snapshot.data ?? [];
          final totalStock = medicines.length;

          return Stack(
            children: [
              const GradientBackground(colors: AppConstants.purpleGradient),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: ImageSlider(
                          imageUrls: [
                            'https://images.unsplash.com/photo-1584036561566-baf8f5f1b144?auto=format&fit=crop&q=80&w=800',
                            'https://images.unsplash.com/photo-1587350846564-929344161a33?auto=format&fit=crop&q=80&w=800',
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
                              'Commercial Dashboard',
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Grow your business with Agri-Tech.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildGlassStatsRow(context, totalStock),
                      ),
                      const SizedBox(height: 32),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Business Operations',
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

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildRecentMedicinesGlass(context, medicines),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlassStatsRow(BuildContext context, int stock) {
    return Row(
      children: [
        Expanded(
          child: _buildGlassStatCard(
            'Inventory',
            '$stock',
            Icons.inventory_2_rounded,
            AppConstants.purpleGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGlassStatCard(
            'Orders',
            '0',
            Icons.shopping_bag_rounded,
            AppConstants.sunsetGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGlassStatCard(
            'Revenue',
            '₹0',
            Icons.payments_rounded,
            AppConstants.primaryGradient,
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.white60),
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
          'Add Medicine',
          Icons.add_circle_rounded,
          AppConstants.sunsetGradient,
          () => _navigateTo(context, const AddMedicineScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Manage Stock',
          Icons.inventory_rounded,
          AppConstants.oceanGradient,
          () => _navigateTo(context, const MedicineInventoryScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Sales History',
          Icons.receipt_long_rounded,
          AppConstants.purpleGradient,
          () => _navigateTo(context, const MedicineOrdersScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Business Reports',
          Icons.analytics_rounded,
          AppConstants.primaryGradient,
          () => _navigateTo(context, const BusinessReportsScreen()),
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

  Widget _buildRecentMedicinesGlass(
    BuildContext context,
    List<MedicineModel> medicines,
  ) {
    final recent = medicines.reversed.take(3).toList();
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Inventory',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () =>
                    _navigateTo(context, const MedicineInventoryScreen()),
                child: Text(
                  'View Full',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Text(
              'No products listed yet.',
              style: GoogleFonts.inter(color: Colors.white54),
            )
          else
            ...recent.map(
              (m) => _buildMedicineItemGlass(m.name, m.category, '₹${m.price}'),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicineItemGlass(String name, String category, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication_rounded, color: Colors.white70),
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
                  category,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
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
