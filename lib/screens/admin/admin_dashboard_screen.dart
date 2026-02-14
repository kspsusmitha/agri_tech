import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../services/session_service.dart';
import '../../services/admin_service.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../role_selection_screen.dart';
import 'user_management_screen.dart';
import 'product_approval_screen.dart';
import 'disease_monitoring_screen.dart';
import 'community_moderation_screen.dart';
import 'admin_requests_screen.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  final ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Admin Nexus',
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
            color: const Color(0xff1a0b2e),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'logout') _showLogoutDialog(context);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: GoogleFonts.inter(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&q=80&w=1920', // Abstract data/network
        gradient: AppConstants.purpleGradient,
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: 24,
                  child: const ImageSlider(
                    imageUrls: [
                      'https://images.unsplash.com/photo-1596253410522-a7e8ea6075bc?auto=format&fit=crop&q=80&w=800',
                      'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&q=80&w=800',
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Intelligence',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time network oversight & metrics.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStatsStream(),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Management Console',
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
                child: _buildRecentActivityStream(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsStream() {
    return StreamBuilder<Map<String, int>>(
      stream: _adminService.streamSystemStats(),
      builder: (context, snapshot) {
        final stats =
            snapshot.data ??
            {
              'totalFarmers': 0,
              'totalBuyers': 0,
              'totalMedicineSellers': 0,
              'pendingProducts': 0,
              'totalOrders': 0,
              'totalMedicineOrders': 0,
            };
        final totalUsers =
            (stats['totalFarmers'] ?? 0) + (stats['totalBuyers'] ?? 0);

        return Row(
          children: [
            Expanded(
              child: _buildGlassStatCard(
                'Users',
                totalUsers.toString(),
                Icons.people_rounded,
                [const Color(0xff4facfe), const Color(0xff00f2fe)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGlassStatCard(
                'Sellers',
                (stats['totalMedicineSellers'] ?? 0).toString(),
                Icons.medical_services_rounded,
                [const Color(0xfff093fb), const Color(0xfff5576c)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGlassStatCard(
                'Orders',
                (stats['totalMedicineOrders'] ?? 0).toString(),
                Icons.medication_rounded,
                [const Color(0xff43e97b), const Color(0xff38f9d7)],
              ),
            ),
          ],
        );
      },
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
      borderRadius: 20,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient.map((c) => c.withOpacity(0.8)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white38,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
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
          'User base',
          Icons.people_outline_rounded,
          AppConstants.oceanGradient,
          () => _navigateTo(context, const UserManagementScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Product Approvals',
          Icons.verified_user_rounded,
          AppConstants.primaryGradient,
          () => _navigateTo(context, const ProductApprovalScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Disease Monitor',
          Icons.bug_report_rounded,
          AppConstants.sunsetGradient,
          () => _navigateTo(context, const DiseaseMonitoringScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Community Hub',
          Icons.forum_rounded,
          AppConstants.oceanGradient,
          () => _navigateTo(context, const CommunityModerationScreen()),
        ),
        _buildActionGlassCard(
          context,
          'Medicine Requests',
          Icons.medical_information_rounded,
          AppConstants.purpleGradient,
          () => _navigateTo(context, const AdminRequestsScreen()),
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
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityStream() {
    return StreamBuilder<List<ProductModel>>(
      stream: _productService.streamAllProducts(),
      builder: (context, snapshot) {
        final products = snapshot.data ?? [];
        final recentProducts = products.take(5).toList();

        return GlassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Real-time activity',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.bolt_rounded,
                    color: Colors.amberAccent,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (recentProducts.isEmpty)
                Text(
                  'No recent activity in the network',
                  style: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
                )
              else
                ...recentProducts.map(
                  (p) => _buildActivityItemGlass(
                    '${p.name} listed for approval',
                    DateFormat('h:mm a').format(p.createdAt),
                    p.status == AppConstants.productPending,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItemGlass(String title, String time, bool isUrgent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isUrgent ? Colors.orangeAccent : Colors.white24,
              shape: BoxShape.circle,
              boxShadow: isUrgent
                  ? [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: isUrgent ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              color: Colors.white24,
              fontSize: 11,
              fontWeight: FontWeight.w500,
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
          backgroundColor: const Color(0xff1a0b2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'End Session',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to exit the admin dashboard?',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white38),
              ),
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
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );
  }
}
